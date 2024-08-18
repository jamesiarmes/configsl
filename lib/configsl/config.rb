# frozen_string_literal: true

require_relative 'dsl'
require_relative 'format'
require_relative 'from_environment'
require_relative 'validation'

module ConfigSL
  # Base class for configuration that includes common functionality.
  class Config
    include DSL
    include Format
    include FromEnvironment
    include Validation

    def initialize(params = {})
      params.each do |name, value|
        set_value(name, value)
      end
    end
  end
end
