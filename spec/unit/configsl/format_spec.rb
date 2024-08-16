# frozen_string_literal: true

RSpec.describe ConfigSL::Format do
  subject(:config) do
    FormatSpecConfig::Config.new(params)
  end

  expected_values = {
    array: %w[one two three],
    boolean_false: false,
    boolean_true: true,
    hash: { one: 1, two: 2, three: 3 },
    integer: 42,
    string: 'rspec_test',
    symbol: :rspec
  }
  unexpected_values = {
    array: Set['one', 'two', 'three'],
    boolean_false: '',
    boolean_true: 1,
    hash: [[:one, 1], [:two, 2], [:three, 3]],
    integer: '42',
    string: :rspec_test,
    symbol: 'rspec'
  }
  incompatible_values = {
    integer: [4, 'two']
  }

  let(:params) { expected_values }

  describe '#get_value' do
    context 'when values are set as expected' do
      expected_values.each do |name, value|
        it "formats the value for #{name}" do
          expect(config.send(name)).to eq(value)
        end
      end
    end

    unexpected_values.each do |name, value|
      context "when #{name} is not set as expected" do
        let(:params) { expected_values.merge(name => value) }

        it 'formats the value' do
          expect(config.send(name)).to eq(expected_values[name])
        end
      end
    end

    incompatible_values.each do |name, value|
      context "when #{name} is an incompatible value" do
        let(:params) { expected_values.merge(name => value) }

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
