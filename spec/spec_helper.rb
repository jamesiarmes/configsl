# frozen_string_literal: true

require 'factory_bot'

# Configure code coverage reporting.
if ENV.fetch('COVERAGE', false)
  require 'simplecov'

  SimpleCov.minimum_coverage 95
  SimpleCov.start do
    add_filter '/spec/'

    track_files 'lib/**/*.rb'
  end
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.shared_context_metadata_behavior = :apply_to_host_groups
end

# Include support files.
require_relative 'support/configs'
