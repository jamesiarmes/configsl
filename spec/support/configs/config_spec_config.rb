# frozen_string_literal: true

class ConfigSpecConfig < ConfigSL::Config
  option :default, type: String, default: 'rspec-default'
  option :optional, type: String
  option :required, type: String, required: true
end
