# frozen_string_literal: true

require_relative 'exception'

module ConfigSL
  # DSL (Domain Specific Language) for defining configuration options.
  #
  # This module provides the base functionality for building configuration
  # classes. It should be included before any other modules that provide
  # additional functionality, such as formatting or validation.
  #
  # The class that includes this module will need to set the values for the
  # options before they can be used. The easiest way to do this is to call
  # `set_value` with each option and its value in the constructor.
  #
  # @example
  #   def initialize(params = {})
  #     params.each do |name, value|
  #       set_value(name, value)
  #     end
  #   end
  module DSL
    # Include the class methods when the module is included.
    def self.included(base)
      base.extend ClassMethods
    end

    # Returns the options hash for the class of the current instance.
    #
    # @return [Hash] The options hash.
    def options
      self.class.options
    end

    # Returns the values of all the options.
    #
    # @return [Array<Hash>] The values of all the options.
    def values
      options.each_key.to_h { |name| [name, get_value(name)] }
    end

    private

    # Gets the value of an option.
    #
    # If the option is not set, it will return the default value.
    #
    # @param name [Symbol] The name of the option.
    # @return [Object] The value of the option.
    #
    # @raise [InvalidOptionError] If the option is not defined.
    def get_value(name)
      raise InvalidOptionError, "Option #{name} is not defined" unless options.key?(name)

      @params.fetch(name, options[name]&.[](:default))
    end

    # Sets the value of an option.
    #
    # @param name [Symbol] The name of the option.
    # @param value [Object] The value to set.
    # @return [Object] The value that was set for the option.
    #
    # @raise [InvalidOptionError] If the option is not defined.
    def set_value(name, value)
      raise InvalidOptionError, "Option #{name} is not defined" unless options.key?(name)

      @params ||= {}
      @params[name] = value
    end

    # Required class methods for the config DSL.
    module ClassMethods
      # Define an option for the class.
      #
      # The keys for the options hash will vary depending on the modules that
      # have been included in your class.
      #
      # @param name [Symbol] The name of the option.
      # @param opts [Hash] The options for the option.
      # @return [void]
      def option(name, opts = {})
        options.merge!({ name => opts })
        define_method(name) { get_value(name) }
      end

      # Returns the options hash for the class.
      #
      # @return [Hash] The options hash.
      def options
        @options ||= {}
      end
    end
  end
end
