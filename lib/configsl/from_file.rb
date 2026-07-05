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

    def self.configsl_source_name
      :file
    end

    # Loads the configuration parameters from a file.
    #
    # @param klass [Class] The class loading the configuration.
    # @param opts [Hash] Options for loading the configuration.
    # @option opts [String] :path Optional path to the file to load; uses the
    #   default path and filename if not specified.
    # @option opts [Symbol] :format Optional format to use for the file; uses
    #   the file extension if not specified.
    # @option opts [Boolean] :defaults Whether to populate default values,
    #   defaults to `true`.
    # @return [Hash] Loaded configuration parameters.
    def self.configsl_load_params(klass, opts = {})
      formats = klass.instance_variable_get(:@config_file_formats) || {}
      return {} if formats.empty?

      path = opts[:path] || klass.configsl_find_file.first
      format = opts[:format] || klass.configsl_find_file_format(File.extname(path))
      data = formats[format][:class].new(path).read

      populate_defaults(klass, data) if opts[:defaults]
      data
    end

    # Populates default values for unset options.
    #
    # @param klass [Class] The class loading the configuration.
    # @param data [Hash] Configuration parameters.
    def self.populate_defaults(klass, data)
      klass.options.each do |name, option_opts|
        name_sym = name.to_sym
        next if data.key?(name_sym) || data.key?(name.to_s)

        data[name_sym] = option_opts[:default]
      end
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
        params = FromFile.configsl_load_params(self, path:, format:, defaults: true)
        new(params)
      end
    end
  end
end
