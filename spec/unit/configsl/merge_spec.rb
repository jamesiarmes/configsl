# frozen_string_literal: true

RSpec.describe ConfigSL::Merge do
  let(:env_vars) do
    {
      'NAME' => 'env-name',
      'ENVIRONMENT' => 'env-environment'
    }
  end

  before do
    ENV.merge!(env_vars)
  end

  after do
    env_vars.each_key { |k| ENV.delete(k) }
  end

  describe 'strict parameter initialization with new' do
    subject(:config_class) { MergeSpecConfig }

    it 'only sets parameters passed to new without loading or merging other sources' do
      config = config_class.new(environment: 'params-environment')

      expect(config).to have_attributes(
        environment: 'params-environment',
        name: be_nil
      )
    end
  end

  describe 'default precedence and merging' do
    subject(:config_class) { MergeSpecConfig }

    it 'defines correct default precedence' do
      expect(config_class.precedence).to eq(%i[params environment file])
    end

    it 'merges values from all sources with default precedence' do
      config = config_class.load(environment: 'params-environment')

      expect(config).to have_attributes(
        name: 'env-name',
        environment: 'params-environment',
        optional: 'default'
      )
    end

    it 'allows custom file path using load with merging' do
      config = config_class.load({}, file: { path: 'spec/support/fixtures/spec-config.json' })

      expect(config).to have_attributes(
        name: 'env-name',
        environment: 'env-environment'
      )
    end

    it 'loads strictly from the file without merging when from_file is called' do
      config = config_class.from_file('spec/support/fixtures/spec-config.json')

      expect(config).to have_attributes(
        name: 'config.json',
        environment: be_nil
      )
    end
  end

  describe 'custom precedence' do
    subject(:config_class) { CustomPrecedenceSpecConfig }

    it 'defines correct custom precedence' do
      expect(config_class.precedence).to eq(%i[file environment params])
    end

    it 'merges values from all sources with custom precedence' do
      config = config_class.load(name: 'params-name', environment: 'params-environment')

      expect(config).to have_attributes(
        name: 'config.yaml',
        environment: 'env-environment'
      )
    end
  end

  describe 'invalid precedence source' do
    subject(:config_class) { MergeSpecConfig }

    it 'raises argument error for invalid source' do
      expect { config_class.precedence(:file, :invalid_source) }.to raise_error(ArgumentError)
    end
  end

  describe 'precedence source exclusion' do
    let(:exclusion_config_class) do
      Class.new(ConfigSL::Config) do
        include ConfigSL::FromFile
        include ConfigSL::FromEnvironment

        precedence :params, :environment
        option :name, type: String
      end
    end

    it 'does not load sources that are excluded from the precedence chain' do
      allow(ConfigSL::FromFile).to receive(:configsl_load_params).and_call_original
      exclusion_config_class.load
      expect(ConfigSL::FromFile).not_to have_received(:configsl_load_params)
    end
  end

  describe 'extensibility with custom config source (e.g. FromVault)' do
    let(:from_vault_module) do
      Module.new do
        def self.configsl_source_name
          :vault
        end

        def self.configsl_load_params(_klass, opts = {})
          key = opts[:key]
          val = key ? "custom-#{key}" : 'vault-value'
          { vault_option: val, name: 'vault-name' }
        end

        def self.included(base)
          base.extend(Module.new do
            def from_vault(key)
              new(vault_option: "custom-#{key}", name: 'vault-name')
            end
          end)
        end
      end
    end

    let(:dynamic_config_class) do
      vault = from_vault_module
      Class.new(ConfigSL::Config) do
        include vault

        option :vault_option, type: String
        option :name, type: String
      end
    end

    it 'automatically registers and discovers the custom source' do
      expect(dynamic_config_class.configsl_available_sources).to include(:vault)
    end

    it 'includes the custom source in default precedence' do
      expect(dynamic_config_class.precedence).to eq(%i[params environment file vault])
    end

    it 'correctly merges values from the custom source' do
      config = dynamic_config_class.load

      expect(config).to have_attributes(
        vault_option: 'vault-value',
        name: 'env-name'
      )
    end

    it 'supports passing custom vault keys via load options' do
      config = dynamic_config_class.load({}, vault: { key: 'my-key' })

      expect(config).to have_attributes(
        vault_option: 'custom-my-key',
        name: 'env-name'
      )
    end
  end
end
