# frozen_string_literal: true

require 'json'

require_relative 'base'

module ConfigSL
  module FileFormat
    # Support for JSON files.
    class Json < Base
      def self.extensions
        %i[json]
      end

      def read
        ::JSON.parse(File.read(@file), symbolize_names: true).each do |name, value|
          yield name, value if block_given?
        end
      end
    end
  end
end
