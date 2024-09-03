# frozen_string_literal: true

RSpec.describe ConfigSL::FileSupport do
  subject(:config) { FromFileSpecConfig::Config }

  describe '.config_file_name' do
    it 'returns the configuration file name' do
      expect(config.config_file_name).to eq('spec-config')
    end
  end

  describe '.config_file_path' do
    it 'returns the configuration file path' do
      expect(config.config_file_path).to eq('spec/support/fixtures')
    end
  end

  describe '.find_file_format' do
    { json: :json, yaml: :yaml, yml: :yaml }.each do |extension, format|
      it "finds the format for the #{extension} extension" do
        expect(config.send(:find_file_format, extension.to_s)).to eq(format)
      end
    end

    it 'raises an error if the format is not found' do
      expect { config.send(:find_file_format, 'txt') }.to \
        raise_error(ConfigSL::FileFormatError)
    end
  end

  describe '.file_extensions' do
    it 'returns all defined file extensions' do
      expect(config.file_extensions).to eq(%i[yaml yml json])
    end

    it 'returns file extensions for JSON' do
      expect(config.file_extensions(format: :json)).to eq(%i[json])
    end

    it 'returns file extensions for YAML' do
      expect(config.file_extensions(format: :yaml)).to eq(%i[yaml yml])
    end

    it 'raises an error if the format is not found' do
      expect { config.file_extensions(format: :txt) }.to \
        raise_error(ConfigSL::FileFormatError)
    end
  end

  describe '.find_file' do
    it 'find the configuration files' do
      expect(config.send(:find_file)).to \
        eq(%w[spec/support/fixtures/spec-config.yaml spec/support/fixtures/spec-config.json])
    end

    it 'finds the configuration file for a specific format' do
      expect(config.send(:find_file, format: :json)).to \
        eq(['spec/support/fixtures/spec-config.json'])
    end

    it 'raises an error if the configuration file is not found' do
      expect { config.send(:find_file, path: 'spec/support.json') }.to \
        raise_error(ConfigSL::FileNotFoundError)
    end
  end
end
