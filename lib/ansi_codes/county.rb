module AnsiCodes
  class County
    Regex = /(.*) (city|Borough|County|City and Borough|Census Area|Municipality|Parish|Islands?|District|Municipio)$/
    attr_reader :state, :ansi_code, :name, :short_name, :designation

    def initialize(state_ansi, county_ansi, name)
      @state = State.find(state_ansi)
      @ansi_code = county_ansi
      @name = name
      match = name.match(Regex)
      @short_name = match && match[1] || name
      @designation = match && match[2] || ''
      freeze
      self.class.instance_variable_get(:@counties)[@state].tap do |counties|
        counties[:ansi_code][@ansi_code.downcase] =
          counties[:name][@name.downcase] = self
      end
    end

    def self.all(state = nil)
      state ? @counties[state][:ansi_code].values :
        @counties.values.flat_map {|values| values[:ansi_code]}.flat_map(&:values)
    end

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
      County.new row[:state_ansi], row[:county_ansi], row[:county_name]
    end
    @counties.values.flat_map(&:values).map(&:freeze)
    @counties.values.map &:freeze
    @counties.freeze
    freeze
  end
end
