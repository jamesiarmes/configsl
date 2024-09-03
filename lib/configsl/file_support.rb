# frozen_string_literal: true

module ConfigSL
  class FileFormatError < ArgumentError; end
  class FileNotFoundError < ArgumentError; end

  # Support for common file operations.
  #
  # This module provides limited functionality itself, but instead provides
  # basic support for configuration files that is leveraged by other modules.
  #
  # Including this modules adds the following DSL methods to your class:
  #
  # - config_file_path: Set the default path to look for configuration files
  # - config_file_name: Set the default file name to look for configuration
  #   files, without extension
  # - register_file_format: Add support for a file format
  module FileSupport
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Required class methods to support file operations.
    module ClassMethods
      # The default name to use for the configuration file.
      #
      # @param filename [String] The name of the configuration file.
      # @return [String] The name of the configuration file.
      def config_file_name(filename = nil)
        @config_file_name = filename unless filename.nil?
        @config_file_name ||= 'config'
      end

      # The default path to use for the configuration file.
      #
      # @param path [String] The path to the configuration file.
      # @return [String] The path to the configuration file.
      def config_file_path(path = nil)
        @config_file_path = path unless path.nil?
        @config_file_path ||= '.'
      end

      # The file extensions supported by this configuration.
      #
      # @param format [Symbol] Optional format to get the extensions for. If
      #   specified, only returns the extensions for that format.
      # @return [Array<String>]
      def file_extensions(format: nil)
        @config_file_formats ||= {}
        if format
          return @config_file_formats[format][:extensions] if @config_file_formats.key?(format)

          raise FileFormatError, "File format not found: #{format}"
        end

        @config_file_formats.values.map { |o| o[:extensions] }.flatten
      end

      # Register support for a file format.
      #
      # @param format [Symbol] The format to register.
      # @param opts [Hash] The options for the format.
      # @option opts [Class] :class The class to use for the format. Defaults to
      #   ConfigSL::FileFormat::`format`, where `format` is capitalized.
      # @option opts [Array<String>] :extensions File extensions for the format.
      #   defaults to those defined in `opts[:class]`.
      def register_file_format(format, opts = {})
        @config_file_formats ||= {}
        opts[:class] ||= ConfigSL::FileFormat.const_get(format.capitalize)
        opts[:extensions] ||= opts[:class].extensions

        @config_file_formats[format] = opts
      end

      private

      # Find the configuration file based on the default path, name, and defined
      # formats.
      #
      # The returned files are ordered based on how their formats are defined.
      # For example:
      #
      #   register_file_format :yaml
      #   register_file_format :json
      #
      # would result in the YAML file being returned first if both are found.
      #
      # @param path [String] Optional path to look for the file. If provided,
      #   this method will raise an error the exact file is not found.
      # @param format [Symbol] Optional format to look for the file in. If
      #   provided, will only match files of the given format. Ignored if `path`
      #   is provided.
      # @return [Array<String>] Array of matching files.
      def find_file(path: nil, format: nil)
        paths = Dir.glob(
          path.nil? ? "#{config_file_name}.{#{file_extensions(format:).join(',')}}" : path,
          base: path.nil? ? config_file_path : nil
        )

        raise FileNotFoundError, 'No configuration file found!' if paths.empty?

        paths.map { |p| File.join(config_file_path, p) }
      end

      # Find the format for a file given its extension.
      #
      # @param extension [String] The file extension to get the format for.
      # @return [Symbol] The format for the file.
      #
      # @raise [FileFormatError] If no file formats have been defined.
      # @raise [FileFormatError] If no file format is found for the extension.
      def find_file_format(extension)
        raise FileFormatError, 'No file formats have been defined' if @config_file_formats.nil?

        extension = extension.sub(/^\./, '').to_sym
        (@config_file_formats || {}).each do |format, opts|
          return format if opts[:extensions].include?(extension)
        end

        raise FileFormatError, "No file format found for extension: #{extension}"
      end
    end
  end
end
