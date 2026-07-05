# frozen_string_literal: true

class CustomPrecedenceSpecConfig < ConfigSL::Config
  config_file_name 'spec-config'
  config_file_path 'spec/support/fixtures'

  register_file_format :yaml
  register_file_format :json

  precedence :file, :environment, :params

  option :name, type: String
  option :environment, type: String
  option :optional, type: String, default: 'default'
  option :format, type: String
  option :nested, type: Hash
end
