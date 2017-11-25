module ProxyFetcher
  class Configuration
    attr_accessor :timeout, :pool_size, :user_agent
    attr_reader :http_client, :proxy_validator, :providers, :adapter

    # rubocop:disable Metrics/LineLength
    DEFAULT_USER_AGENT = 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112 Safari/537.36'.freeze

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
      @user_agent = DEFAULT_USER_AGENT
      @pool_size = 10
      @timeout = 3
      @http_client = HTTPClient
      @proxy_validator = ProxyValidator

      self.providers = self.class.registered_providers
      self.adapter = :nokogiri
    end

    def adapter=(name_or_class)
      @adapter = ProxyFetcher::Document::Adapters.lookup(name_or_class)
      @adapter.setup!

      @adapter
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
