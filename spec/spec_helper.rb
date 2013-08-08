begin
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    add_filter {|source| source.lines.count < 10}
  end
rescue LoadError
  STDERR.puts 'SimpleCov not installed.  Not generating coverage report.'
end

require 'ansi_codes'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end
