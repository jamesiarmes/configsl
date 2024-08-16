# frozen_string_literal: true

require_relative '../../../lib/configsl/dsl'
require_relative '../../../lib/configsl/validation'

RSpec.describe ConfigSL::Validation do
  subject(:config) do
    ValidationSpecConfig.new(params)
  end

  valid_params = { required: 'rspec-config', enum: :two }.freeze
  invalid_params = { required: nil, enum: :invalid }.freeze

  let(:params) { valid_params }

  describe '#valid?' do
    context 'when the configuration is valid' do
      it 'validates the configuration' do
        expect(config.valid?).to be(true)
      end
    end

    invalid_params.each do |name, value|
      context "when the #{name} option is invalid" do
        let(:params) { valid_params.merge(name => value) }

        it 'validates the configuration' do
          expect(config.valid?).to be(false)
        end
      end
    end
  end

  describe '#validate!' do
    context 'when the configuration is valid' do
      it 'does not raise an exception' do
        expect { config.validate! }.not_to raise_error
      end
    end

    invalid_params.each do |name, value|
      context "when the #{name} option is invalid" do
        let(:params) { valid_params.merge(name => value) }

        it 'validates the configuration' do
          expect { config.validate! }.to raise_error(ConfigSL::ValidationError)
        end
      end
    end
  end
end
