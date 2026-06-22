# frozen_string_literal: true

RSpec.describe ConfigSL::Collection do
  subject(:config) do
    CollectionSpecConfig::Config.new(params)
  end

  let(:params) do
    {
      subarray: [{ name: 'sub1' }, { name: 'sub2' }],
      subhash: { sub1: { name: 'sub1' }, sub2: { name: 'sub2' } },
      keyarray: [{ name: 'sub1', index: 42 }, { name: 'sub2' }],
      keyhash: { sub1: { name: 'sub1' }, sub2: { name: 'sub2', key: 'existing' } }
    }
  end
  let(:subconfigs) do
    [
      CollectionSpecConfig::SubConfig.new(name: 'sub1'),
      CollectionSpecConfig::SubConfig.new(name: 'sub2')
    ]
  end

  describe '#set_value' do
    context 'when the type is array' do
      it 'sets a properly typed value' do
        expect(config.send(:set_value, :subarray, [{ name: 'sub3' }])).to \
          match([an_object_having_attributes(name: 'sub3')])
      end

      it 'raises on a hash value' do
        expect { config.send(:set_value, :subarray, { sub1: { name: 'sub1' } }) }.to \
          raise_error(ConfigSL::InvalidValueError, /Invalid value type.*expected Array/)
      end
    end
  end

  describe '#configsl_collected?' do
    context 'when the option type is array' do
      it 'returns true if the values have been collected' do
        expect(config.send(:configsl_collected?, :subarray, subconfigs)).to be true
      end

      it 'returns true if there are no values' do
        expect(config.send(:configsl_collected?, :subarray, [])).to be true
      end

      it 'returns false if values have not been collected' do
        expect(config.send(:configsl_collected?, :subarray, params[:subarray])).to be false
      end
    end

    context 'when the option type is hash' do
      it 'returns true if the values have been collected' do
        expect(config.send(:configsl_collected?, :subhash, { sub1: subconfigs[0], sub2: subconfigs[1] })).to be true
      end

      it 'returns true if there are no values' do
        expect(config.send(:configsl_collected?, :subhash, {})).to be true
      end

      it 'returns false if values have not been collected' do
        expect(config.send(:configsl_collected?, :subhash, params[:subhash])).to be false
      end
    end
  end

  describe '#configsl_collect_values' do
    context 'when the option is an array' do
      let(:values) { params[:subarray] }

      it 'returns a collection of the appropriate types' do
        expect(config.send(:configsl_collect_values, :subarray, values)).to \
          all be_a(CollectionSpecConfig::SubConfig)
      end

      it 'returns a collection with the appropriate values' do
        expect(config.send(:configsl_collect_values, :subarray, values)).to contain_exactly(
          an_object_having_attributes(name: subconfigs[0].name),
          an_object_having_attributes(name: subconfigs[1].name)
        )
      end

      it 'only collects the values once' do
        # This expectation would fail if it re-collected the values because the
        # object instances would be different.
        expect(config.send(:configsl_collect_values, :subarray, subconfigs)).to eq(subconfigs)
      end
    end

    context 'when the option is a hash' do
      let(:values) { params[:subhash] }
      let(:subconfigs) { super().to_h { |c| [c.name.to_sym, c] } }

      it 'returns a collection of the appropriate types' do
        expect(config.send(:configsl_collect_values, :subhash, values).values).to \
          all be_a(CollectionSpecConfig::SubConfig)
      end

      it 'returns a collection with the appropriate values' do
        expect(config.send(:configsl_collect_values, :subhash, values)).to match(
          sub1: an_object_having_attributes(name: subconfigs[:sub1].name),
          sub2: an_object_having_attributes(name: subconfigs[:sub2].name)
        )
      end

      it 'only collects the values once' do
        # This expectation would fail if it re-collected the values because the
        # object instances would be different.
        expect(config.send(:configsl_collect_values, :subhash, subconfigs)).to eq(subconfigs)
      end
    end
  end

  describe '#format_value' do
    context 'when the option is an array' do
      let(:values) { params[:subarray] }

      it 'returns an empty array for nil' do
        expect(config.send(:format_value, :subarray, nil)).to eq([])
      end

      it 'returns an empty array when empty' do
        expect(config.send(:format_value, :subarray, [])).to eq([])
      end

      it 'returns collected values' do
        expect(config.send(:format_value, :subarray, values)).to contain_exactly(
          an_object_having_attributes(name: subconfigs[0].name),
          an_object_having_attributes(name: subconfigs[1].name)
        )
      end

      context 'when a key has been specified' do
        let(:values) { params[:keyarray] }

        it 'sets the key values' do
          expect(config.send(:format_value, :keyarray, values)).to contain_exactly(
            an_object_having_attributes(index: 42),
            an_object_having_attributes(index: 1)
          )
        end
      end
    end

    context 'when the option is a hash' do
      let(:values) { params[:subhash] }
      let(:subconfigs) { super().to_h { |c| [c.name.to_sym, c] } }

      it 'returns an empty hash for nil' do
        expect(config.send(:format_value, :subhash, nil)).to eq({})
      end

      it 'returns an empty hash when empty' do
        expect(config.send(:format_value, :subhash, {})).to eq({})
      end

      it 'returns collected values' do
        expect(config.send(:format_value, :subhash, values)).to match(
          sub1: an_object_having_attributes(name: subconfigs[:sub1].name),
          sub2: an_object_having_attributes(name: subconfigs[:sub2].name)
        )
      end

      context 'when a key has been specified' do
        let(:values) { params[:keyhash] }

        it 'sets the key values' do
          expect(config.send(:format_value, :keyhash, values).values).to contain_exactly(
            an_object_having_attributes(key: 'sub1'),
            an_object_having_attributes(key: 'existing')
          )
        end
      end
    end
  end
end
