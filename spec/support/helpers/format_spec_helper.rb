# frozen_string_literal: true

module FormatSpecHelper
  def self.expected_values
    {
      array: %w[one two three],
      boolean_false: false,
      boolean_true: true,
      hash: { one: 1, two: 2, three: 3 },
      integer: 42,
      string: 'rspec_test',
      symbol: :rspec
    }
  end

  def self.incompatible_values
    {
      integer: [4, 'two']
    }
  end

  def self.unexpected_values
    {
      array: Set['one', 'two', 'three'],
      boolean_false: '',
      boolean_true: 1,
      hash: [[:one, 1], [:two, 2], [:three, 3]],
      integer: '42',
      string: :rspec_test,
      symbol: 'rspec'
    }
  end
end
