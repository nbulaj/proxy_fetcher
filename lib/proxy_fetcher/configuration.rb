module ProxyFetcher
  class Configuration
    WrongCustomClass = Class.new(StandardError)

    attr_accessor :providers, :connection_timeout
    attr_accessor :http_client, :proxy_validator, :logger

    class << self
      def providers_registry
        @registry ||= ProvidersRegistry.new
      end

      def register_provider(name, klass)
        providers_registry.register(name, klass)
      end

      def registered_providers
        providers_registry.providers.keys
      end
    end

    def initialize
      reset!
    end

    def reset!
      @connection_timeout = 3
      @http_client = HTTPClient
      @proxy_validator = ProxyValidator

      self.providers = [:hide_my_name] # currently default one
    end

    def providers=(value)
      @providers = Array(value)
    end

    alias provider= providers=

    def http_client=(klass)
      @http_client = setup_custom_class(klass, required_methods: :fetch)
    end

    def proxy_validator=(klass)
      @proxy_validator = setup_custom_class(klass, required_methods: :connectable?)
    end

    private

    def setup_custom_class(klass, required_methods: [])
      unless klass.respond_to?(*required_methods)
        raise WrongCustomClass, "#{klass} must respond to [#{Array(required_methods).join(', ')}] class methods!"
      end

      klass
    end
  end
end
