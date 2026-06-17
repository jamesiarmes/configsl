# frozen_string_literal: true

RSpec.describe ConfigSL::Format do
  subject(:config) do
    FormatSpecConfig::Config.new(params)
  end

  let(:params) { FormatSpecHelper.expected_values }

  describe '#get_value' do
    context 'when values are set as expected' do
      FormatSpecHelper.expected_values.each do |name, value|
        it "formats the value for #{name}" do
          expect(config.send(name)).to eq(value)
        end
      end
    end

    FormatSpecHelper.unexpected_values.each do |name, value|
      context "when #{name} is not set as expected" do
        let(:params) { FormatSpecHelper.expected_values.merge(name => value) }

        it 'formats the value' do
          expect(config.send(name)).to eq(FormatSpecHelper.expected_values[name])
        end
      end
    end

    FormatSpecHelper.incompatible_values.each do |name, value|
      context "when #{name} is an incompatible value" do
        let(:params) { FormatSpecHelper.expected_values.merge(name => value) }

        it 'raises an exception' do
          expect { config.send(name) }.to raise_exception(ConfigSL::FormatError)
        end
      end
    end

    context 'when a sub-config is set' do
      let(:params) { super().merge(sub: { substring: :first, subint: '13' }) }

      it 'instantiates the sub-config' do
        expect(config.sub).to be_instance_of(FormatSpecConfig::SubConfig)
      end
    end
  end
end
