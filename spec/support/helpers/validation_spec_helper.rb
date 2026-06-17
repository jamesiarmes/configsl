# frozen_string_literal: true

module ValidationSpecHelper
  def self.invalid_params
    {
      required: nil,
      enum: :invalid
    }
  end

  def self.valid_params
    {
      required: 'rspec-config',
      enum: :two
    }
  end
end
