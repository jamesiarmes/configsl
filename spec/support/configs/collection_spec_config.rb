# frozen_string_literal: true

class CollectionSpecConfig
  class Base
    include ConfigSL::DSL
    include ConfigSL::Format
    include ConfigSL::Collection

    def initialize(params = {})
      params.each do |name, value|
        set_value(name, value)
      end
    end
  end

  class SubConfig < Base
    option :name, type: String
  end

  class Config < Base
    option :title, type: String
    option :array, type: Array
    option :hash, type: Hash

    option :subarray, type: Array, collection: SubConfig
    option :subhash, type: Hash, collection: SubConfig
    option :substring, type: String, collection: SubConfig
  end
end
