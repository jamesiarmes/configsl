# frozen_string_literal: true

module FromFileSpecConfig
  class Base
    include ConfigSL::DSL

    def initialize(params = {})
      params.each do |name, value|
        set_value(name, value)
      end
    end
  end

  class Nested < Base
    option :title, type: String
  end

  class Config < Base
    include ConfigSL::FromFile

    config_file_name 'spec-config'
    config_file_path 'spec/support/fixtures'

    register_file_format :yaml
    register_file_format :json

    option :format, type: Symbol
    option :name, type: String
    option :nested, type: Nested
  end
end
