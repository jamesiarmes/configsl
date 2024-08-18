# frozen_string_literal: true

module ConfigSL
  class ValidationError < RuntimeError; end

  # Validates configuration options.
  #
  # This will check that all required options are set. Additionally, you can
  # set `enum` to an array of valid values for an option.
  #
  #   option :state, type: String, required: true, enum: %w[on off]
  #
  # @todo Implement custom validations.
  module Validation
    # Determine if the configuration is valid.
    #
    # @return [Boolean]
    def valid?
      options.keys.all? { |name| option_valid?(name) }
    end

    # Validate the configuration and raise an error if it is invalid.
    #
    # @raise [ValidationError] If the configuration is invalid.
    def validate!
      raise ValidationError, 'Invalid configuration' unless valid?
    end

    private

    # Validates a single option.
    #
    # @param name [Symbol] The name of the option.
    # @return [Boolean]
    def option_valid?(name)
      valid = !options[name][:required] || get_value(name)
      valid &&= options[name][:enum].include?(get_value(name)) if options[name][:enum]

      valid
    end
  end
end
