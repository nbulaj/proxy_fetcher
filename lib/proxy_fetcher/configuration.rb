# frozen_string_literal: true

module ProxyFetcher
  # ProxyFetcher configuration. Stores all the options for dealing
  # with HTTP requests, adapters, custom classes.
  #
  class Configuration
    # @!attribute timeout
    #   @return [Integer] HTTP request connection / open timeout
    attr_accessor :timeout

    # @!attribute pool_size
    #   @return [Integer] proxy validator pool size (max number of threads)
    attr_accessor :pool_size

    # @!attribute user_agent
    #   @return [String] User-Agent string
    attr_accessor :user_agent

    # @!attribute [r] adapter
    #   @return [Object] HTML parser adapter
    attr_reader :adapter

    # @!attribute [r] http_client
    #   @return [Class] HTTP client class
    attr_reader :http_client

    # @!attribute [r] proxy_validator
    #   @return [Class] proxy validator class
    attr_reader :proxy_validator

    # @!attribute [r] providers
    #   @return [Array<String>, Array<Symbol>] proxy providers list to be used
    attr_reader :providers

    # User-Agent string that will be used by the ProxyFetcher HTTP client (to
    # send requests via proxy) and to fetch proxy lists from the sources.
    #
    # Default is Google Chrome 60, but can be changed in <code>ProxyFetcher.config</code>.
    #
    DEFAULT_USER_AGENT = 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 ' \
                         '(KHTML, like Gecko) Chrome/60.0.3112 Safari/537.36'.freeze

    # HTML parser adapter name.
    #
    # Default is Nokogiri, but can be changed in <code>ProxyFetcher.config</code>.
    #
    DEFAULT_ADAPTER = :nokogiri

    class << self
      # Registry for handling proxy providers.
      #
      # @return [ProxyFetcher::ProvidersRegistry]
      #   providers registry
      #
      def providers_registry
        @registry ||= ProvidersRegistry.new
      end

      # Register new proxy provider. Requires provider name and class
      # that will process proxy list.
      #
      # @param name [String, Symbol]
      #   name of the provider
      #
      # @param klass [Class]
      #   Class that will fetch and process proxy list
      #
      def register_provider(name, klass)
        providers_registry.register(name, klass)
      end

      # Returns registered providers names.
      #
      # @return [Array<String>, Array<Symbol>]
      #   registered providers names
      #
      def registered_providers
        providers_registry.providers.keys
      end
    end

    # Initialize ProxyFetcher configuration with default options.
    #
    # @return [ProxyFetcher::Configuration]
    #   ProxyFetcher gem configuration object
    #
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
    end

    # Setups HTML parser adapter for all the proxy providers.
    #
    # @param name_or_class [String, Symbol, Class]
    #   name of the adapter or it's class
    #
    def adapter=(name_or_class)
      @adapter = ProxyFetcher::Document::Adapters.lookup(name_or_class)
      @adapter.setup!
    end

    # Setups collection of providers that will be used to fetch proxies.
    #
    # @param value [String, Symbol, Array<String>, Array<Symbol>]
    #   provider names
    #
    def providers=(value)
      @providers = Array(value)
    end

    alias provider providers
    alias provider= providers=

    # Setups HTTP client class that will be used to fetch proxy lists.
    # Validates class for the required methods to be defined.
    #
    # @param klass [Class]
    #   HTTP client class
    #
    def http_client=(klass)
      @http_client = setup_custom_class(klass, required_methods: :fetch)
    end

    # Setups class that will be used to validate proxy lists.
    # Validates class for the required methods to be defined.
    #
    # @param klass [Class]
    #   Proxy validator class
    #
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
