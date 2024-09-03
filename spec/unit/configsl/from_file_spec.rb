# frozen_string_literal: true

RSpec.describe ConfigSL::FromFile do
  subject(:config) { FromFileSpecConfig::Config }

  describe '.from_file' do
    it 'loads the configuration for the first defined format' do
      expect(config.from_file.name).to eq('config.yaml')
    end

    it 'loads the specified configuration file' do
      expect(
        config.from_file('spec/support/fixtures/spec-config.json').name
      ).to eq('config.json')
    end
  end
end
