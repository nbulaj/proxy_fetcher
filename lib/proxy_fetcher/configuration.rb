module ProxyFetcher
  class Configuration
    UnknownProvider = Class.new(StandardError)
    RegisteredProvider = Class.new(StandardError)
    WrongHttpClient = Class.new(StandardError)

    attr_accessor :http_client, :connection_timeout
    attr_accessor :provider

    class << self
      def providers
        @providers ||= {}
      end

      def register_provider(name, klass)
        raise RegisteredProvider, "`#{name}` provider already registered!" if providers.key?(name.to_sym)

        providers[name.to_sym] = klass
      end
    end

    def initialize
      reset!
    end

    def reset!
      @connection_timeout = 3
      @http_client = HTTPClient

      self.provider = :hide_my_name # currently default one
    end

    def provider=(name)
      @provider = self.class.providers[name.to_sym]

      raise UnknownProvider, "unregistered proxy provider `#{name}`!" if @provider.nil?
    end

    def http_client=(klass)
      unless klass.respond_to?(:fetch, :connectable?)
        raise WrongHttpClient, "#{klass} must respond to #fetch and #connectable? class methods!"
      end

      @http_client = klass
    end
  end
end
