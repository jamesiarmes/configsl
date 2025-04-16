# frozen_string_literal: true

RSpec.describe ConfigSL::Collection do
  subject(:config) do
    CollectionSpecConfig::Config.new(params)
  end

  let(:params) do
    {
      subarray: [{ name: 'sub1' }, { name: 'sub2' }],
      subhash: { sub1: { name: 'sub1' }, sub2: { name: 'sub2' } }
    }
  end
  let(:subconfigs) do
    [
      CollectionSpecConfig::SubConfig.new(name: 'sub1'),
      CollectionSpecConfig::SubConfig.new(name: 'sub2')
    ]
  end

  describe '#collection?' do
    context 'when the option is not marked as a collection' do
      it 'returns false for an array option' do
        expect(config.send(:collection?, :array)).to be false
      end

      it 'returns false for a hash option' do
        expect(config.send(:collection?, :hash)).to be false
      end

      it 'returns false for a string option' do
        expect(config.send(:collection?, :title)).to be false
      end
    end

    context 'when the option is marked as a collection' do
      it 'returns true for an array option' do
        expect(config.send(:collection?, :subarray)).to be true
      end

      it 'returns true for a hash option' do
        expect(config.send(:collection?, :subhash)).to be true
      end

      it 'returns false for a string option' do
        expect(config.send(:collection?, :substring)).to be false
      end
    end
  end

  describe '#collected?' do
    context 'when the option type is array' do
      it 'returns true if the values have been collected' do
        expect(config.send(:collected?, :subarray, subconfigs)).to be true
      end

      it 'returns true if there are no values' do
        expect(config.send(:collected?, :subarray, [])).to be true
      end

      it 'returns false if values have not been collected' do
        expect(config.send(:collected?, :subarray, params[:subarray])).to be false
      end
    end

    context 'when the option type is hash' do
      it 'returns true if the values have been collected' do
        expect(config.send(:collected?, :subhash, { sub1: subconfigs[0], sub2: subconfigs[1] })).to be true
      end

      it 'returns true if there are no values' do
        expect(config.send(:collected?, :subhash, {})).to be true
      end

      it 'returns false if values have not been collected' do
        expect(config.send(:collected?, :subhash, params[:subhash])).to be false
      end
    end
  end

  describe '#collect_values' do
    context 'when the option is an array' do
      let(:values) { params[:subarray] }

      it 'returns a collection of the appropriate types' do
        expect(config.send(:collect_values, :subarray, values)).to \
          all be_a(CollectionSpecConfig::SubConfig)
      end

      it 'returns a collection with the appropriate values' do
        expect(config.send(:collect_values, :subarray, values)).to contain_exactly(
          an_object_having_attributes(name: subconfigs[0].name),
          an_object_having_attributes(name: subconfigs[1].name)
        )
      end

      it 'only collects the values once' do
        # This expectation would fail if it re-collected the values because the
        # object instances would be different.
        expect(config.send(:collect_values, :subarray, subconfigs)).to eq(subconfigs)
      end
    end

    context 'when the option is a hash' do
      let(:values) { params[:subhash] }
      let(:subconfigs) { super().to_h { |c| [c.name.to_sym, c] } }

      it 'returns a collection of the appropriate types' do
        expect(config.send(:collect_values, :subhash, values).values).to \
          all be_a(CollectionSpecConfig::SubConfig)
      end

      it 'returns a collection with the appropriate values' do
        expect(config.send(:collect_values, :subhash, values)).to match(
          sub1: an_object_having_attributes(name: subconfigs[:sub1].name),
          sub2: an_object_having_attributes(name: subconfigs[:sub2].name)
        )
      end

      it 'only collects the values once' do
        # This expectation would fail if it re-collected the values because the
        # object instances would be different.
        expect(config.send(:collect_values, :subhash, subconfigs)).to eq(subconfigs)
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
        expect(config.send(:collect_values, :subhash, values)).to match(
          sub1: an_object_having_attributes(name: subconfigs[:sub1].name),
          sub2: an_object_having_attributes(name: subconfigs[:sub2].name)
        )
      end
    end
  end
end
