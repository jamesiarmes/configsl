# frozen_string_literal: true

module ConfigSL
  # Converts a confirguation value to a hash structure.
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
      when ConfigSL::DSL
        val.to_h
      when Array
        configsl_serialize_array(val)
      when Hash
        configsl_serialize_hash(val)
      else
        val
      end
    end

    # Serializes array values.
    #
    # @param array [Array] Array to serialize.
    # @return [Array] Serialized array.
    def configsl_serialize_array(array)
      array.map { |item| item.is_a?(ConfigSL::DSL) ? item.to_h : item }
    end

    # Serializes hash values.
    #
    # @param hash [Hash] Hash to serialize.
    # @return [Hash] Serialized hash.
    def configsl_serialize_hash(hash)
      hash.transform_values { |item| item.is_a?(ConfigSL::DSL) ? item.to_h : item }
    end
  end
end
