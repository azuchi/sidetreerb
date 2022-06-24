# frozen_string_literal: true

require "sidetree"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def fixture_file(relative_path)
  file = File.read(fixture_path(relative_path))
  JSON.parse(file)
end

def fixture_path(relative_path)
  File.join(File.dirname(__FILE__), "fixtures", relative_path)
end
