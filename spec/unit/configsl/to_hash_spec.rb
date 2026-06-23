# frozen_string_literal: true

RSpec.describe ConfigSL::ToHash do
  subject(:config) { ToHashSpecConfig::Config.new(params) }

  describe '#to_h' do
    context 'when values are simple objects' do
      let(:params) { { name: 'test_name' } }

      it 'returns the simple values as-is' do
        expect(config.to_h).to eq(name: 'test_name')
      end
    end

    context 'when a value is nil' do
      let(:params) { { name: nil } }

      it 'returns nil for the value' do
        expect(config.to_h).to eq(name: nil)
      end
    end

    context 'when a value is a nested config' do
      let(:sub_config) { ToHashSpecConfig::SubConfig.new(name: 'nested_name') }
      let(:params) { { sub_config: sub_config } }

      it 'serializes the nested config' do
        expect(config.to_h).to eq(sub_config: { name: 'nested_name' })
      end
    end

    context 'when a value is an array' do
      let(:sub_config) { ToHashSpecConfig::SubConfig.new(name: 'nested_name') }

      context 'with config objects' do
        let(:params) { { sub_configs_array: [sub_config] } }

        it 'serializes config objects inside the array' do
          expect(config.to_h).to eq(sub_configs_array: [{ name: 'nested_name' }])
        end
      end

      context 'with non-config objects' do
        let(:params) { { sub_configs_array: ['non_config'] } }

        it 'leaves non-config objects as-is' do
          expect(config.to_h).to eq(sub_configs_array: ['non_config'])
        end
      end

      context 'when empty' do
        let(:params) { { sub_configs_array: [] } }

        it 'returns an empty array' do
          expect(config.to_h).to eq(sub_configs_array: [])
        end
      end
    end

    context 'when a value is a hash' do
      let(:sub_config) { ToHashSpecConfig::SubConfig.new(name: 'nested_name') }

      context 'with config objects' do
        let(:params) { { sub_configs_hash: { sub: sub_config } } }

        it 'serializes config objects inside the hash' do
          expect(config.to_h).to eq(sub_configs_hash: { sub: { name: 'nested_name' } })
        end
      end

      context 'with non-config objects' do
        let(:params) { { sub_configs_hash: { sub: 'non_config' } } }

        it 'leaves non-config objects as-is' do
          expect(config.to_h).to eq(sub_configs_hash: { sub: 'non_config' })
        end
      end

      context 'when empty' do
        let(:params) { { sub_configs_hash: {} } }

        it 'returns an empty hash' do
          expect(config.to_h).to eq(sub_configs_hash: {})
        end
      end
    end

    context 'when values have deeply nested recursion' do
      let(:nested_sub_config) { ToHashSpecConfig::SubConfig.new(name: 'deep_name') }
      let(:sub_config) { ToHashSpecConfig::SubConfig.new(name: 'nested_name', recurse: nested_sub_config) }

      context 'with nested config objects' do
        let(:params) { { sub_config: sub_config } }

        it 'serializes deeply nested configs recursively' do
          expect(config.to_h).to eq(
            sub_config: {
              name: 'nested_name',
              recurse: { name: 'deep_name' }
            }
          )
        end
      end

      context 'with deeply nested arrays and hashes' do
        let(:params) do
          {
            sub_configs_array: [
              [sub_config]
            ],
            sub_configs_hash: {
              outer: {
                inner: sub_config
              }
            }
          }
        end

        it 'serializes nested arrays and hashes recursively' do
          expect(config.to_h).to eq(
            sub_configs_array: [
              [{ name: 'nested_name', recurse: { name: 'deep_name' } }]
            ],
            sub_configs_hash: {
              outer: {
                inner: { name: 'nested_name', recurse: { name: 'deep_name' } }
              }
            }
          )
        end
      end
    end

    context 'when the config includes collections' do
      subject(:config) { ToHashSpecConfig::WithCollections.new(params) }

      context 'with an array collection' do
        let(:params) do
          {
            array_collection: [
              { name: 'first' },
              { name: 'second' }
            ]
          }
        end

        it 'serializes the array collection members' do
          expect(config.to_h).to eq(
            array_collection: [
              { name: 'first', index: 0 },
              { name: 'second', index: 1 }
            ]
          )
        end
      end

      context 'with a hash collection' do
        let(:params) do
          {
            hash_collection: {
              first: { name: 'first' },
              second: { name: 'second' }
            }
          }
        end

        it 'serializes the hash collection members' do
          expect(config.to_h).to eq(
            hash_collection: {
              first: { name: 'first', key: :first },
              second: { name: 'second', key: :second }
            }
          )
        end
      end
    end
  end
end
