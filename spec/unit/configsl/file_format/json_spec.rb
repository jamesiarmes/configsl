# frozen_string_literal: true

RSpec.describe ConfigSL::FileFormat::Json do
  it_behaves_like 'a file format', 'config.json', %i[json], {
    format: 'JSON',
    name: 'config.json',
    nested: { title: 'JSON file for testing' }
  }
end
