# frozen_string_literal: true

require 'facets/boolean'

module ConfigSL
  class FormatError < ArgumentError; end

  # Format option values.
  #
  # This will format the values of the defined options when they are set on the
  # config object. It will also format the values when they are retrieved, if
  # they don't match their defined type.
  #
  # The default behavior is to cast the value as the defined type. If the value
  # is nil, it will be returned as is.
  #
  # @todo Should we add an option to cast nil?
  module Format
    FORMATTERS = {
      Array => :to_a,
      FalseClass => :to_b,
      Hash => :to_h,
      Integer => :to_i,
      String => ->(v) { v.to_s.encode('utf-8') },
      Symbol => :to_sym,
      TrueClass => :to_b
    }.freeze

    private

    def get_value(name)
      value = super
      format_value(name, value)
    end

    def set_value(name, value)
      raise InvalidOptionError, "Option #{name} is not defined" unless options.key?(name)

      super(name, format_value(name, value))
    end

    def format_value(option, value)
      return value if value.nil? || value.is_a?(options[option][:type])

      apply_formatter(value, options[option][:type])
    rescue StandardError => e
      raise FormatError, "Value for #{option} is not compatible with " \
                         "#{options[option][:type]}: #{e.message}"
    end

    def apply_formatter(value, formatter)
      if FORMATTERS.key?(formatter)
        return value.send(FORMATTERS[formatter]) if FORMATTERS[formatter].is_a?(Symbol)
        return FORMATTERS[formatter].call(value) if FORMATTERS[formatter].is_a?(Proc)
      end

      formatter.new(value)
    end
  end
end
