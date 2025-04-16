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
  # @todo Should we raise an exception if type is not Hash or Array?
  module Collection
    def self.included(base)
      base.include(Format) unless base.include?(Format)
    end

    private

    # Determines if an option is a collection.
    #
    # @param option [String] Option to check.
    # @return [Boolean]
    def collection?(option)
      options[option].fetch(:collection, false) &&
        [Array, Hash].include?(options[option][:type])
    end

    # Determines if the values in a collection have been collected.
    #
    # @param option [String] Option being checked.
    # @param values [Array, Hash] Values for the option.
    # @return [Boolean]
    def collected?(option, values)
      return true if values.empty?

      value = options[option][:type] == Array ? values.first : values.values.first
      value.is_a?(options[option][:collection])
    end

    # Collects values into an appropriate collection.
    #
    # @param option [String] Option whose values are being collected.
    # @param values [Array, Hash] Values to collect.
    # @return [Array, Hash]
    def collect_values(option, values)
      return values if collected?(option, values)

      collection = values.map do |value|
        collect_value(option, value)
      end

      return collection if options[option][:type] == Array

      collection.to_h
    end

    # Collect a single value to be added to the collection.
    #
    # @param option [String] Option whose value is being collected.
    # @param value [Object] The value to be added to the collection.
    # @return [Array, Hash]
    def collect_value(option, value)
      params = options[option][:type] == Array ? value : value[1]
      config = options[option][:collection].new(params)
      options[option][:type] == Array ? config : [value[0], config]
    end

    # @see Format#format_value
    def format_value(option, value)
      return super unless collection?(option)

      return collect_values(option, value) unless value.nil? || value.empty?

      formatter = Format::FORMATTERS[options[option][:type]]
      value.send(formatter)
    end
  end
end
