# frozen_string_literal: true

module ConfigSL
  # Load configuration from the environment.
  #
  # This module provides a way to load configuration values from environment
  # variables. It checks for a variables using the name of the option, in upper
  # snake case (e.g. `MY_OPTION`). You can add a prefix to all variable names
  # using `from_environment_prefix`.
  #
  #   from_environment_prefix 'DATABASE_'
  #   option :host, default: 'localhost'
  #
  # You can override the variable name for individual options by setting
  # `env_variable`.
  #
  #   option :host, default: 'localhost', env_variable: 'DB_HOST'
  module FromEnvironment
    def self.included(base)
      base.extend ClassMethods
      base.from_environment_prefix ''
    end

    def self.configsl_source_name
      :environment
    end

    # Loads the configuration parameters from environment variables.
    #
    # @param klass [Class] The class loading the configuration.
    # @param opts [Hash] Options for loading the configuration.
    # @option opts [Boolean] :defaults Whether to populate default values,
    #   defaults to `true`
    # @return [Hash] Loaded configuration parameters.
    def self.configsl_load_params(klass, opts = {})
      klass.options.each_with_object({}) do |(name, option_opts), hash|
        env_var = option_opts[:env_variable] || name.to_s.upcase
        if ENV.key?(env_var)
          hash[name] = ENV[env_var]
        elsif opts[:defaults]
          hash[name] = option_opts[:default]
        end
      end
    end

    # Class methods necessary for loading configuration from the environment.
    module ClassMethods
      # Set the prefix for environment variables.
      #
      # @param prefix [String] The prefix for the environment variables.
      def from_environment_prefix(prefix)
        @from_environment_prefix = prefix
      end

      # Create a new instance of the class using values from the environment.
      #
      # @return [self] The new config object
      def from_environment
        params = FromEnvironment.configsl_load_params(self, defaults: true)
        new(params)
      end

      # Ensure each option has an environment variable defined.
      def option(name, opts = {})
        opts[:env_variable] ||= "#{@from_environment_prefix}#{name.to_s.upcase}"
        super
      end
    end
  end
end
