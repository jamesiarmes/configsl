# frozen_string_literal: true

class FormatSpecConfig
  class Base
    include ConfigSL::DSL
    include ConfigSL::Format

    def initialize(params = {})
      params.each do |name, value|
        set_value(name, value)
      end
    end
  end

  class SubConfig < Base
    option :substring, type: String
    option :subint, type: Integer
  end

  class Config < Base
    option :array, type: Array
    option :boolean_false, type: FalseClass
    option :boolean_true, type: TrueClass
    option :hash, type: Hash
    option :integer, type: Integer
    option :string, type: String
    option :symbol, type: Symbol
    option :sub, type: SubConfig
  end
end
