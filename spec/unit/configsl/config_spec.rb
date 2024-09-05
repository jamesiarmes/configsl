# frozen_string_literal: true

RSpec.describe ConfigSL::Config do
  subject(:config) { ConfigSpecConfig }

  describe '#initialize' do
    it 'raises an error for unknown options' do
      expect { config.new(unknown: 'rspec') }.to \
        raise_error(ConfigSL::InvalidOptionError)
    end

    it 'sets values for hash keys' do
      instance = config.new(required: 'rspec')

      expect(instance.required).to eq('rspec')
    end

    it 'sets values for string keys' do
      instance = config.new('required' => 'rspec')

      expect(instance.required).to eq('rspec')
    end
  end
end
