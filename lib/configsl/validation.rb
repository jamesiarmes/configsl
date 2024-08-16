# frozen_string_literal: true

module ConfigSL
  class ValidationError < RuntimeError; end

  # Validates configuration options.
  module Validation
    def valid?
      options.keys.all? { |name| option_valid?(name) }
    end

    def validate!
      raise ValidationError, 'Invalid configuration' unless valid?
    end

    private

    def option_valid?(name)
      valid = !options[name][:required] || !!get_value(name)
      valid &&= options[name][:enum].include?(get_value(name)) if options[name][:enum]

      valid
    end
  end
end
