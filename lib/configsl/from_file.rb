# frozen_string_literal: true

require_relative 'file_support'

module ConfigSL
  # Load configuration from a file.
  #
  # This module provides a way to load configuration values from a file. It
  # searches for files based on a default path, name, and one or more file
  # formats.
  #
  # When multiple files are found, they will be sorted based on the order their
  # formats are defined, and the first file will be loaded.
  #
  # For example:
  #
  #   config_file_path 'config'
  #   config_file_name 'config'
  #
  #   register_file_format :yaml
  #   register_file_format :json
  #
  # will search for files in the `config` directory, with the name `config`, and
  # with the extensions `.yaml`, `.yml` and `.json`. If both `config.yaml` and
  # `config.json` are found, `config.yaml` will be loaded.
  #
  # This module depends on the `FileSupport` module and will it include it your
  # class if it has not been so already.
  module FromFile
    def self.included(base)
      base.include(FileSupport) unless base.include?(FileSupport)
      base.extend(ClassMethods)
    end

    # Required class methods for loading config files.
    module ClassMethods
      # Loads configuration from a file.
      #
      # If no path is specified, uses the file file that matches the default
      # path, name, and file formats. If multiple files are found, they will be
      # sorted based on the order the file formats are defined, adn the first
      # file will be load.
      #
      # @param path [String] Optional path to the file to load.
      # @param format [Symbol] Optional format to use for the file. Uses the
      #   file extension if not specified.
      # @return [self]
      def from_file(path = nil, format: nil)
        path ||= find_file.first
        format ||= find_file_format(File.extname(path))
        file = @config_file_formats[format][:class].new(path)
        new(file.read)
      end
    end
  end
end
