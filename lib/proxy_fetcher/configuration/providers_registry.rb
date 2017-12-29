# frozen_string_literal: true

module ProxyFetcher
  # ProxyFetcher providers registry that stores all registered proxy providers.
  class ProvidersRegistry
    # Returns providers hash where <i>key</i> is the name of the provider
    # and <i>value</i> is an associated class.
    #
    # @return [Hash]
    #   registered providers
    #
    def providers
      @providers ||= {}
    end

    # Add custom provider to common registry.
    # Requires proxy provider name ('proxy_docker' for example) and a class
    # that implements the parsing logic.
    #
    # @param name [String, Symbol]
    #   provider name
    #
    # @param klass [Class]
    #   provider class
    #
    # @raise [ProxyFetcher::Exceptions::RegisteredProvider]
    #   provider already registered
    #
    def register(name, klass)
      raise ProxyFetcher::Exceptions::RegisteredProvider, name if providers.key?(name.to_sym)

      providers[name.to_sym] = klass
    end

    # Returns a class for specific provider if it is registered
    # in the registry. Otherwise throws an exception.
    #
    # @param provider_name [String, Symbol]
    #   provider name
    #
    # @return [Class]
    #   provider class
    #
    # @raise [ProxyFetcher::Exceptions::UnknownProvider]
    #   provider is unknown
    #
    def class_for(provider_name)
      provider_name = provider_name.to_sym

      providers.fetch(provider_name)
    rescue KeyError
      raise ProxyFetcher::Exceptions::UnknownProvider, provider_name
    end
  end
end
