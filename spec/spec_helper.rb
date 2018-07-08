require 'simplecov'
require 'coveralls'
Coveralls.wear!
SimpleCov.start

require 'jirify'

RSpec.configure do |config|
  original_stderr = $stderr
  original_stdout = $stdout

  config.before(:all) do
    # Redirect stderr and stdout
    $stderr = File.new(File.join(File.dirname(__dir__), 'spec', 'test_stderr.txt'), 'w')
    $stdout = File.new(File.join(File.dirname(__dir__), 'spec', 'test_stdout.txt'), 'w')
  end

  config.after(:all) do
    $stderr = original_stderr
    $stdout = original_stdout
  end
end

def mock_config
  file = File.join(File.dirname(__dir__), 'spec/mocks/', '.jirify.mock')
  YAML.load_file(file)['options']
end
