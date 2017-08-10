module ProxyFetcher
  class Configuration
    UnknownProvider = Class.new(StandardError)
    RegisteredProvider = Class.new(StandardError)

    attr_accessor :open_timeout, :read_timeout, :provider

    class << self
      def providers
        @providers ||= {}
      end

      def register_provider(name, klass)
        raise RegisteredProvider, "#{name} provider already registered!" if providers.key?(name.to_sym)

        providers[name.to_sym] = klass
      end
    end

    def initialize
      @open_timeout = 3
      @read_timeout = 3

      self.provider = :hide_my_name # currently default one
    end

    def provider=(name)
      @provider = self.class.providers[name.to_sym]

      raise UnknownProvider, "unregistered proxy provider (#{name})!" if @provider.nil?
    end
  end
end
