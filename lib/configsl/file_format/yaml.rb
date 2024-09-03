# frozen_string_literal: true

require 'yaml'

require_relative 'base'

module ConfigSL
  module FileFormat
    # Support for YAML files.
    class Yaml < Base
      def self.extensions
        %i[yaml yml]
      end

      def read
        ::YAML.load_file(@file, symbolize_names: true).each do |name, value|
          yield name, value if block_given?
        end
      end
    end
  end
end
