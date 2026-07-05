# frozen_string_literal: true

module ConfigSL
  # Support merging configurations from multiple sources based on precedence.
  module Merge
    def self.included(base)
      base.extend ClassMethods
    end

    # Class methods to manage precedence and loading of sources.
    module ClassMethods
      # Load config from all available sources and merge them in order.
      #
      # @param params [Hash] Configuration parameters to merge in at the highest
      #   precedence.
      # @param source_options [Hash] Optional per-source configuration options.
      # @return [self] Configuration object with merged parameters.
      def load(params = {}, source_options = {})
        merged_params = configsl_load_merged_params(params, source_options)
        new(merged_params)
      end

      # Set or get precedence order
      #
      # @param sources [Array<Symbol>] List of sources in order of priority,
      #   highest to lowest precedence.
      # @return [Array<Symbol>] Full list of sources in precedence order.
      def precedence(*sources)
        sources = sources.flatten
        if sources.any?
          configsl_validate_precedence_sources(sources)
          @precedence = sources
        else
          @precedence || configsl_default_precedence
        end
      end

      # Return the available sources dynamically discovered from ancestors
      #
      # @return [Array<Symbol>]
      def configsl_available_sources
        [:params] + ancestors.select { |ancestor| ancestor.respond_to?(:configsl_source_name) }
                             .map(&:configsl_source_name)
      end

      private

      # Returns the default precedence order.
      #
      # +:params+ has the highest precedence, followed by included sources in
      # the order they were included.
      #
      # @return [Array<Symbol>] Default source precedence order.
      def configsl_default_precedence
        # Ancestors are listed in reverse order of inclusion, so we filter
        # modules that are config sources and reverse the array to order them by
        # inclusion.
        modules = ancestors.select { |ancestor| ancestor.respond_to?(:configsl_source_name) }
        [:params] + modules.reverse.map(&:configsl_source_name)
      end

      # Loads configs from all available sources and merges them in order.
      #
      # @param params [Hash] Configuration parameters to merge in at the highest
      #   precedence.
      # @param opts [Hash] Optional per-source configuration options.
      # @return [Hash] Merged parameters.
      def configsl_load_merged_params(params = {}, opts = {})
        params = params.is_a?(Hash) ? params.transform_keys(&:to_sym) : {}
        sources = { params: params }

        configsl_load_sources(sources, opts)
        configsl_merge_sources_by_precedence(sources)
      end

      # Loads configuration data from all registered config sources.
      #
      # If an explicit precedence has been defined, only sources configured in
      # the chain will be loaded.
      #
      # @param sources [Hash{Symbol => Hash}] Hash for loaded sources.
      # @param opts [Hash] Optional per-source configuration options.
      def configsl_load_sources(sources, opts = {})
        ancestors.each do |ancestor|
          next unless ancestor.respond_to?(:configsl_source_name)

          source_name = ancestor.configsl_source_name.to_sym
          next unless precedence.include?(source_name)

          source_opts = opts[source_name] || {}
          sources[source_name] ||=
            ancestor.configsl_load_params(self, source_opts)
        end
      end

      # Merges all loaded configuration sources in precedence order.
      #
      # @param sources [Hash{Symbol => Hash}] Loaded configuration hashes.
      # @return [Hash] Merged configuration parameters.
      def configsl_merge_sources_by_precedence(sources)
        merged = {}
        precedence.reverse_each do |source|
          merged.merge!(sources[source] || {})
        end

        merged
      end

      # Validates that all specified precedence sources are available.
      #
      # @param sources [Array<Symbol>] The sources to validate.
      #
      # @raise [ArgumentError] If any source is invalid.
      def configsl_validate_precedence_sources(sources)
        invalid = sources - configsl_available_sources
        return if invalid.empty?

        msg = "Invalid precedence sources: #{invalid.join(', ')}. " \
              "Available: #{configsl_available_sources.join(', ')}"
        raise ArgumentError, msg
      end
    end
  end
end
