# frozen_string_literal: true

module ToHashSpecConfig
  class Base
    include ConfigSL::DSL
    include ConfigSL::ToHash

    def initialize(params = {})
      params.each do |name, value|
        set_value(name, value)
      end
    end
  end

  class SubConfig < Base
    option :name, type: String
    option :index, type: Integer
    option :key, type: Symbol
  end

  class Config < Base
    option :name, type: String
    option :sub_config, type: SubConfig
    option :sub_configs_array, type: Array
    option :sub_configs_hash, type: Hash
  end

  class WithCollections < Base
    include ConfigSL::Format
    include ConfigSL::Collection

    option :array_collection, type: Array, collection: { type: SubConfig, key: :index }
    option :hash_collection, type: Hash, collection: { type: SubConfig, key: :key }
  end
end
