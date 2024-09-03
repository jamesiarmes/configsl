# frozen_string_literal: true

RSpec.describe ConfigSL::FileFormat::Yaml do
  it_behaves_like 'a file format', 'spec-config.yaml', %i[yaml yml], {
    format: 'YAML',
    name: 'config.yaml',
    nested: { title: 'YAML file for testing' }
  }
end
