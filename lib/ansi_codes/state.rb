require 'csv'

module AnsiCodes
  class State
    attr_reader :ansi_code, :name, :abbreviation

    def initialize(ansi_code, name, abbreviation)
      @ansi_code = ansi_code
      @name = name
      @abbreviation = abbreviation
      freeze
      self.class.instance_variable_get(:@states).tap do |states|
        states[:ansi_code][@ansi_code.downcase] =
          states[:name][@name.downcase] =
          states[:abbreviation][@abbreviation.downcase] = self
      end
    end

    def counties

    end

    @states = { ansi_code: {}, name: {}, abbreviation: {} }
    data_file = File.expand_path('../../../data/state.txt', __FILE__)
    options = { col_sep: '|', headers: true, header_converters: :symbol }
    CSV.foreach(data_file, options) do |row|
      State.new row[:state], row[:state_name], row[:stusab]
    end
    @states.values.map &:freeze
    @states.freeze

    def self.find(value)
      case value
      when Fixnum
        value = '%02d' % value
        selector = :ansi_code
      when String
        begin
          Integer(value)
          selector = :ansi_code
        rescue ArgumentError
          selector = value.size == 2 ? :abbreviation : :name
        end
      else
        raise(ArgumentError, 'Argument must be an integer or a string.')
      end
      @states[selector][value.downcase].tap do |result|
        raise(RuntimeError, "No state found for lookup '#{value}'") unless result
        yield result if block_given?
      end
    end

    def self.all
      @all ||= @states[:ansi_code].values
    end
  end
end
