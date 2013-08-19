module AnsiCodes
  # A representation of US counties and equivalent census areas.
  # County instances are created at class load time and are immutable.
  class County
    # include AnsiCodes::ActiveModel::County

    # @return [State] the {State} that this county belongs to
    attr_reader :state_ansi
    # @return [String] the three digit ANSI code for this county
    attr_reader :county_ansi
    # @return [String] the county's full name in title case
    attr_reader :name
    # @return [String] the county name, minus the designation
    # @note some cities have no designation, so this attribute will be the same as {#name}
    attr_reader :short_name
    # @return [String] the census designation (County, Parish, Municipio, etc.)
    # @note some cities have no designation, in which case this will return the empty string
    attr_reader :designation

    # @return [State] The {State} instance that this county belongs to
    def state
      State.find(state_ansi)
    end

    private

    class << self
      private :new
    end

    # Suffixes for counties (parishes, etc.) to help split names into their parts.
    DESIGNATIONS = /(.*) (city|Borough|County|City and Borough|Census Area|Municipality|Parish|Islands?|District|Municipio)$/

    # Create a new County instance.
    # @note This is only meant to be called internally during class loading.
    #       You cannot call #new directly.
    # @param state_ansi [String] the two-digit state ANSI code
    # @param county_ansi [String] the three-digit county ANSI code
    # @param name [String] the county name
    def initialize(state_ansi, county_ansi, name)
      @state_ansi, @county_ansi, @name = state_ansi, county_ansi, name
      match = name.match(DESIGNATIONS)
      @short_name = match && match[1] || name
      @designation = match && match[2] || ''
    end

    public

    # @param [State] state an optional {State} object to narrow the results
    # @return [Array<County>] all counties or all of a {State}'s counties if one is provided
    def self.all(state = nil)
      state ? counties[state][:county_ansi].values :
        counties.values.flat_map { |values| values[:county_ansi] }.flat_map(&:values)
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
      state = State.find(state) unless state.is_a?(State)
      case county
      when Fixnum
        county, selector = '%03d' % county, :county_ansi
      when String
        selector = county =~ /^[0-9]{3}$/ ? :county_ansi : :name
      else
        raise(ArgumentError, 'Argument must be an integer or a string.')
      end
      counties[state][selector][county.downcase].tap do |result|
        raise(RuntimeError, "No county found for lookup '#{county}' in state #{state.name}") unless result
        yield result if block_given?
      end
    end

    private

    def self.counties
      @counties ||= Hash[
        read_csv.group_by(&:state).map do |state, list|
          [state, {
            county_ansi: Hash[list.map(&:county_ansi).map(&:downcase).zip(list)].freeze,
            name: Hash[list.map(&:name).map(&:downcase).zip(list)].freeze
          }.freeze]
        end
      ].freeze
    end

    def self.read_csv
      file = File.expand_path('../../../data/national_county.txt', __FILE__)
      options = { headers: true, header_converters: :symbol }
      CSV.read(file, options).map do |row|
        new(*row.values_at(:state_ansi, :county_ansi, :county_name))
      end
    end
  end
end
