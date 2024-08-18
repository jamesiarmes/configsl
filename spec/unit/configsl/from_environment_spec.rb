# frozen_string_literal: true

RSpec.describe ConfigSL::FromEnvironment do
  subject(:config) do
    FromEnvironmentSpecConfig::Config
  end

  let(:vars) do
    {
      'CUSTOM_ENV' => 'custom value',
      'ENVIRONMENT' => 'rspec-test',
      'TEST_VAR' => 'test variable'
    }
  end

  before do
    ENV.merge!(vars)
  end

  describe '.from_environment' do
    it 'uses the default when no value is present' do
      expect(config.from_environment.default).to eq('default')
    end

    it 'uses the option name for the variable by default' do
      expect(config.from_environment.environment).to eq(vars['ENVIRONMENT'])
    end

    it 'uses the overridden variable now' do
      expect(config.from_environment.custom).to eq(vars['CUSTOM_ENV'])
    end
  end

  describe '.from_environment_prefix' do
    subject(:config) do
      FromEnvironmentSpecConfig::WithPrefix
    end

    it 'uses the prefix for the environment variable' do
      expect(config.from_environment.var).to eq(vars['TEST_VAR'])
    end
  end
end
