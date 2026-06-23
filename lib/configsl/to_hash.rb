# frozen_string_literal: true

module ConfigSL
  # Converts a configuration value to a hash structure.
  module ToHash
    def to_h
      configsl_params.to_h { |k, v| [k, configsl_serialize_value(v)] }
    end

    private

    # Recursively serializes configuration values.
    #
    # @param val [Object] Value to serialize.
    # @return [Object] Serialized value.
    def configsl_serialize_value(val)
      case val
      when nil then nil
      when Array then configsl_serialize_array(val)
      when Hash then configsl_serialize_hash(val)
      else val.respond_to?(:to_h) ? val.to_h : val
      end
    end

    # Serializes array values.
    #
    # @param array [Array] Array to serialize.
    # @return [Array] Serialized array.
    def configsl_serialize_array(array)
      array.map { |item| configsl_serialize_value(item) }
    end

    # Serializes hash values.
    #
    # @param hash [Hash] Hash to serialize.
    # @return [Hash] Serialized hash.
    def configsl_serialize_hash(hash)
      hash.transform_values { |item| configsl_serialize_value(item) }
    end
  end
end
