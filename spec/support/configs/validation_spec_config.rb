# frozen_string_literal: true

class ValidationSpecConfig
  include ConfigSL::DSL
  include ConfigSL::Validation

  option :enum, type: Symbol, enum: %i[one two three], required: true
  option :default, type: String, default: 'rspec-default'
  option :optional, type: String
  option :required, type: String, required: true

  def initialize(params = {})
    params.each do |name, value|
      set_value(name, value)
    end
  end
end
