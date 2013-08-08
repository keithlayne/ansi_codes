module AnsiCodes
  # A representation of US counties and equivalent census areas.
  # County instances are created at class load time and are immutable.
  class County
    # @return [State] the {State} that this county belongs to
    attr_reader :state
    # @return [String] the three digit ANSI code for this county
    attr_reader :ansi_code
    # @return [String] the county's full name in title case
    attr_reader :name
    # @return [String] the county name, minus the designation
    # @note some cities have no designation, so this attribute will be the same as {#name}
    attr_reader :short_name
    # @return [String] the census designation (County, Parish, Municipio, etc.)
    # @note some cities have no designation, in which case this will return the empty string
    attr_reader :designation

    private

    # Suffixes for counties (parishes, etc.) to help split names into their parts.
    Designations = /(.*) (city|Borough|County|City and Borough|Census Area|Municipality|Parish|Islands?|District|Municipio)$/

    # Create a new County instance.
    # @note This is only meant to be called internally during class loading.
    #       You cannot call #new directly.
    # @param state_ansi [String] the two-digit state ANSI code
    # @param county_ansi [String] the three-digit county ANSI code
    # @param name [String] the county name
    def initialize(state_ansi, county_ansi, name)
      @state = State.find(state_ansi)
      @ansi_code = county_ansi
      @name = name
      match = name.match(Designations)
      @short_name = match && match[1] || name
      @designation = match && match[2] || ''
      freeze
      self.class.instance_variable_get(:@counties)[@state].tap do |counties|
        counties[:ansi_code][@ansi_code.downcase] =
          counties[:name][@name.downcase] = self
      end
    end

    public

    # @param [State] state an optional {State} object to narrow the results
    # @return [Array<County>] all counties or all of a {State}'s counties if one is provided
    def self.all(state = nil)
      state ? @counties[state][:ansi_code].values :
        @counties.values.flat_map {|values| values[:ansi_code]}.flat_map(&:values)
    end

    # Look up a county by state and county ANSI code or name
    # @param [State, Fixnum, String] state the state portion of the query.
    #   This method will accept a {State} object or anything that {State.find} will accept.
    # @param [Fixnum, String] county the county ANSI code or name to look up
    # @return [County] the {County} associated with the query parameters
    # @raise [ArgumentError] if the county parameter is not a Fixnum or String,
    #   or if the state parameter is not a {State}, Fixnum, or String.
    # @raise [RuntimeError] if no associated {State} or {County} is found
    def self.find(state, county)
      state = state.is_a?(State) ? state : State.find(state)
      case county
      when Fixnum
        county, selector = '%03d' % county, :ansi_code
      when String
        selector = county =~ /^[0-9]{3}$/ ? :ansi_code : :name
      else raise(ArgumentError, 'Argument must be an integer or a string.')
      end
      @counties[state][selector][county.downcase].tap do |result|
        raise(RuntimeError, "No county found for lookup '#{county}' in state #{state.name}") unless result
        yield result if block_given?
      end
    end

    @counties = Hash[State.all.map {|state| [state, { ansi_code: {}, name: {} }] }]
    data_file = File.expand_path('../../../data/national_county.txt', __FILE__)
    options = { headers: true, header_converters: :symbol }
    CSV.foreach(data_file, options) do |row|
      new row[:state_ansi], row[:county_ansi], row[:county_name]
    end
    @counties.values.flat_map(&:values).map(&:freeze)
    @counties.values.map &:freeze
    @counties.freeze
    freeze
  end
end
