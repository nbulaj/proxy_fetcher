module ProxyFetcher
  class Configuration
    attr_accessor :providers, :timeout, :pool_size
    attr_accessor :http_client, :proxy_validator

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

    # Sets default configuration options
    def reset!
      @pool_size = 10
      @timeout = 3
      @http_client = HTTPClient
      @proxy_validator = ProxyValidator

      self.providers = self.class.registered_providers
    end

    def providers=(value)
      @providers = Array(value)
    end

    alias provider providers
    alias provider= providers=

    def http_client=(klass)
      @http_client = setup_custom_class(klass, required_methods: :fetch)
    end

    def proxy_validator=(klass)
      @proxy_validator = setup_custom_class(klass, required_methods: :connectable?)
    end

    private

    # Checks if custom class has some required class methods
    def setup_custom_class(klass, required_methods: [])
      unless klass.respond_to?(*required_methods)
        raise ProxyFetcher::Exceptions::WrongCustomClass.new(klass, required_methods)
      end

      klass
    end
  end
end
