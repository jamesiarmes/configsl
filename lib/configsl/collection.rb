# frozen_string_literal: true

require_relative 'format'

module ConfigSL
  # Support options as collections.
  #
  # This will format the values of the defined options when they are set on the
  # config object. It will also format the values when they are retrieved, if
  # they don't match their defined type.
  #
  # The default behavior is to cast the value as the defined type. If the value
  # is nil, it will be returned as is.
  #
  # @example Use the shorthand syntax to define a collection with no additional
  #   options
  #
  #   class TestConfig < ConfigSL::Config
  #     include ConfigSL::Collection
  #
  #     option :subarray, type: Array, collection: SubConfig
  #     option :subhash, type: Hash, collection: SubConfig
  #   end
  #
  # @example Automatically set a key on the collection members based on their
  #   index (arrays) or keys (hashes), unless the key is already set
  #
  #   class TestConfig < ConfigSL::Config
  #     include ConfigSL::Collection
  #
  #     option :subarray, type: Array, collection: { type: SubConfig, key: :index }
  #     option :subhash, type: Hash, collection: { type: SubConfig, key: :name }
  #   end
  module Collection
    def self.included(base)
      base.include(Format) unless base.include?(Format)
      base.extend ClassMethods
    end

    # Class methods necessary for defining collection options.
    module ClassMethods
      # @see DSL#option
      def option(name, opts = {})
        # If the option was set using the shorthand syntax, convert it to an
        # options hash for consistent handling.
        opts[:collection] = { type: opts[:collection], key: nil } \
          if opts[:collection].is_a?(Class)

        super
      end
    end

    private

    # @see DSL#set_value
    #
    # @raise [InvalidValueError] If the value is not of the expected type.
    def set_value(name, value)
      configsl_option_exists!(name)
      if configsl_collection?(name) &&
         !value.nil? &&
         !value.is_a?(options[name][:type])
        # If the option is a collection, we want to make sure the value is of the
        # expected type.
        raise InvalidValueError,
              "Invalid value type (#{value.class}) for collection " \
              "option #{name}; expected #{options[name][:type]}"
      end

      super
    end

    # Determines if an option is a collection.
    #
    # @param option [Symbol] Option to check.
    # @return [Boolean]
    def configsl_collection?(option)
      options[option].fetch(:collection, false) &&
        [Array, Hash].include?(options[option][:type])
    end

    # Determines if the values in a collection have been collected.
    #
    # @param option [Symbol] Option being checked.
    # @param values [Array, Hash] Values for the option.
    # @return [Boolean]
    def configsl_collected?(option, values)
      return true if values.empty?

      value = options[option][:type] == Array ? values.first : values.values.first
      value.is_a?(options[option][:collection][:type])
    end

    # Collects values into an appropriate collection.
    #
    # @param option [Symbol] Option whose values are being collected.
    # @param values [Array, Hash] Values to collect.
    # @return [Array, Hash] Collected values as the defined type.
    #
    # @raise [InvalidValueError] If the values are not of the correct type.
    def configsl_collect_values(option, values)
      return values if configsl_collected?(option, values)

      if values.is_a?(Hash)
        configsl_collect_hash(option, values)
      else
        configsl_collect_array(option, values)
      end
    end

    # Collect values for an array collection.
    #
    # @param option [Symbol] Option being processed.
    # @param values [Array] Values to collect.
    # @return [Array] Collected values.
    def configsl_collect_array(option, values)
      values.map.with_index do |value, index|
        configsl_collect_value(option, value, index)
      end
    end

    # Collect values for a hash collection.
    #
    # @param option [Symbol] Option being processed.
    # @param values [Hash] Values to collect.
    # @return [Hash] Collected values.
    def configsl_collect_hash(option, values)
      values.to_h do |key, value|
        configsl_collect_value(option, [key, value], key)
      end
    end

    # Collect a single value to be added to the collection.
    #
    # @param option [Symbol] Option whose value is being collected.
    # @param value [Object] The value to be added to the collection.
    # @return [Array, Hash]
    def configsl_collect_value(option, value, index = nil)
      is_array = options[option][:type] == Array
      params = is_array ? value : value[1]
      configsl_collection_key(params, options[option][:collection][:key], index)

      config = options[option][:collection][:type].new(params)
      is_array ? config : [value[0], config]
    end

    def configsl_collection_key(value, key, index)
      return if key.nil? || index.nil?
      return value[key] unless value[key].nil?

      value[key] = index
    end

    # @see Format#format_value
    def format_value(option, value)
      return super unless configsl_collection?(option)

      return configsl_collect_values(option, value) unless value.nil? || value.empty?

      formatter = Format::FORMATTERS[options[option][:type]]
      value.send(formatter)
    end
  end
end
