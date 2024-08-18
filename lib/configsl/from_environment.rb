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
        params = options.transform_values do |opts|
          ENV.fetch(opts[:env_variable], opts[:default])
        end

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
