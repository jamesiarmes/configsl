# frozen_string_literal: true

class FromEnvironmentSpecConfig
  class Base
    include ConfigSL::DSL
    include ConfigSL::FromEnvironment

    def initialize(params = {})
      params.each do |name, value|
        set_value(name, value)
      end
    end
  end

  class Config < Base
    option :default, default: 'default'
    option :environment, default: 'rspec'
    option :custom, default: 'custom', env_variable: 'CUSTOM_ENV'
  end

  class WithPrefix < Base
    from_environment_prefix 'TEST_'

    option :var, default: 'variable'
  end
end
