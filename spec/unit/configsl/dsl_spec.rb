# frozen_string_literal: true

require_relative '../../../lib/configsl/dsl'

RSpec.describe ConfigSL::DSL do
  subject(:config) do
    DSLSpecConfig
  end

  let(:expected_options) { %i[enum default optional required] }

  describe '.option' do
    it 'adds an option' do
      expect(config.instance_variable_get(:@options).keys).to eq(expected_options)
    end

    it 'adds all options' do
      expect(config.instance_variable_get(:@options)[:enum]).to eq(
        type: Symbol, enum: %i[one two three], required: true
      )
    end
  end

  describe '.options' do
    it 'returns the options' do
      expect(config.options.keys).to eq(expected_options)
    end
  end

  describe '#options' do
    subject(:instance) { config.new }

    it 'returns the options' do
      expect(instance.options.keys).to eq(expected_options)
    end
  end

  describe '#values' do
    subject(:instance) { config.new(required: 'rspec-config', enum: :two) }

    it 'returns the values for all options' do
      expect(instance.values.keys).to eq(expected_options)
    end

    it 'returns the values' do
      expect(instance.values).to eq(
        default: 'rspec-default',
        enum: :two,
        optional: nil,
        required: 'rspec-config'
      )
    end
  end

  describe '#get_value' do
    subject(:instance) { config.new(required: 'rspec-config', enum: :two) }

    it 'returns the value' do
      expect(instance.required).to eq('rspec-config')
    end

    it 'raises an error for unknown options' do
      expect { instance.unknown }.to raise_error(NoMethodError)
    end

    context 'when the values is not set' do
      it 'returns the default value' do
        expect(instance.default).to eq('rspec-default')
      end

      it 'returns nil with no default' do
        expect(instance.optional).to be_nil
      end
    end
  end

  describe '#respond_to_missing?' do
    subject(:instance) { config.new(required: 'rspec-config', enum: :two) }

    it 'returns true for known options' do
      expected_options.each do |key|
        expect(instance.respond_to?(key)).to be(true)
      end
    end

    it 'returns false for unknown options' do
      expect(instance.respond_to?(:unknown)).to be(false)
    end
  end
end
