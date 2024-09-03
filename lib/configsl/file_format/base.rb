# frozen_string_literal: true

module ConfigSL
  module FileFormat
    # Base class for file format support.
    #
    # @abstract Subclass and override `#read` and `.extensions` to implement a
    # file format.
    class Base
      def initialize(file)
        @file = file
      end

      # Extensions used to identify the file format.
      #
      # Values should be returned in order of preference.
      #
      # @return [Array<Symbol>] The extensions used to identify the file format.
      def self.extensions
        []
      end

      # Reads the file and returns a hash of configuration values.
      #
      # @return [Hash{Symbol => Object}]
      #
      # @raise [NotImplementedError] If not implemented.
      def read
        raise NotImplementedError, 'Not implemented'
      end
    end
  end
end
