# frozen_string_literal: true

shared_examples 'a file format' do |filename, extensions, expected|
  subject(:file) { described_class.new(path) }

  let(:path) { "spec/support/fixtures/#{filename}" }

  describe '.extensions' do
    it 'returns the JSON extension' do
      expect(described_class.extensions).to eq(extensions)
    end
  end

  describe '#read' do
    it 'returns a hash of configuration values' do
      expect(file.read).to eq(expected)
    end
  end
end
