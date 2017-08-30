module ProxyFetcher
  class ProvidersRegistry
    def providers
      @providers ||= {}
    end

    # Add custom provider to common registry.
    # Requires proxy provider name ('hide_my_name' for example) and a class
    # that implements the parsing logic.
    def register(name, klass)
      raise ProxyFetcher::Exceptions::RegisteredProvider, name if providers.key?(name.to_sym)

      providers[name.to_sym] = klass
    end

    # Returns a class for specific provider if it is
    # registered in the registry. Otherwise throws an exception.
    def class_for(provider_name)
      provider_name = provider_name.to_sym

      providers.fetch(provider_name)
    rescue KeyError
      raise ProxyFetcher::Exceptions::UnknownProvider, provider_name
    end
  end
end
