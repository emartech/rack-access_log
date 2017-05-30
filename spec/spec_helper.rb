require "bundler/setup"
require "rack/access_log"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSpec::Matchers.define "log_with" do |logger, level, message|
  supports_block_expectations

  match do |actual|
    expect(logger).to receive(level).with(message)
    execute_with_error_handling(&actual)
    true
  end

  def execute_with_error_handling
    yield
  rescue
    nil
  end
end
