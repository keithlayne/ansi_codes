require 'simplecov'
require 'coveralls'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter '/spec/'
  add_filter {|source| source.lines.count < 10}
end

begin
  require 'active_model'

  shared_examples_for "ActiveModel" do
    require 'test/unit/assertions'
    require 'active_model/lint'
    include Test::Unit::Assertions
    include ActiveModel::Lint::Tests

    ActiveModel::Lint::Tests.public_instance_methods.map(&:to_s).grep(/^test/).each do |method|
      example(method.gsub('_', ' ')) { send method }
    end
  end

rescue LoadError
  STDERR.puts 'ActiveModel not installed.  Not running lint tests.'
end


require 'ansi_codes'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end
