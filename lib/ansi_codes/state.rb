require 'csv'

module AnsiCodes
  # A representation of US states and equivalent census areas.
  # State instances are created at class load time and are immutable.
  class State
#    include AnsiCodes::ActiveModel::State

# @return [String] the two-digit ANSI code string
# @api public
    attr_reader :ansi_code
    # @return [String] the state name in title case
    # @api public
    attr_reader :name
    # @return [String] the two-letter state abbreviation in caps
    # @api public
    attr_reader :abbreviation

    class << self
      private :new
    end

    private

    # Create a new State instance.
    # @note This is only meant to be called internally during class loading.
    #       You should not call {State.new} directly.
    # @param ansi_code [String] the two-digit state ANSI code
    # @param name [String] the state name
    # @param abbreviation [String] the two-letter state abbreviation
    def initialize(ansi_code, name, abbreviation)
      @ansi_code, @name, @abbreviation = ansi_code, name, abbreviation
    end

    public

    # @return [Array<County>] all of this state's counties
    # @api public
    # @!attribute [r] counties
    def counties
      County.all(self)
    end

    # Look up a state by ANSI code, abbreviation, or name
    # @param [Fixnum, String] value the lookup query
    # @return [State] the {State} associated with the query parameter
    # @raise [ArgumentError] if the argument is not a Fixnum or String
    # @raise [RuntimeError] if no associated {State} is found
    def self.find(value)
      case value
      when Fixnum
        value = '%02d' % value
        selector = :ansi_code
      when String
        selector = if value =~ /\d{2}/
                     :ansi_code
                   elsif value.size == 2
                     :abbreviation
                   else
                     :name
                   end
      else
        raise(ArgumentError, 'Argument must be an integer or a string.')
      end
      states[selector][value.downcase].tap do |result|
        raise(RuntimeError, "No state found for lookup '#{value}'") unless result
        yield result if block_given?
      end
    end

    # @return [Array<State>] an array of all states
    def self.all
      states[:ansi_code].values
    end

    private

    def self.states
      @states ||= Hash[
        (states = read_csv) && [:ansi_code, :name, :abbreviation].map do |key|
          [key, Hash[states.map(&key).map(&:downcase).zip(states)].freeze]
        end
      ].freeze
    end

    def self.read_csv
      file = File.expand_path('../../../data/state.txt', __FILE__)
      options = { col_sep: '|', headers: true, header_converters: :symbol }
      CSV.read(file, options).map do |row|
        state = new(*row.values_at(:state, :state_name, :stusab))
        const_set(state.name.gsub(/[ .]/, '_').upcase, state)
      end
    end

    states # preload so constants are defined
  end
end
