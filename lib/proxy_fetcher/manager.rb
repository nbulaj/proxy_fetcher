# frozen_string_literal: true

module ProxyFetcher
  # ProxyFetcher Manager class for interacting with proxy lists from various providers.
  class Manager
    # @!attribute [r] proxies
    #   @return [Array<ProxyFetcher::Proxy>] An array of proxies
    attr_reader :proxies

    # Initialize ProxyFetcher Manager instance for managing proxies
    #
    # refresh: true - load proxy list from the remote server on initialization
    # refresh: false - just initialize the class, proxy list will be empty ([])
    #
    # @return [Manager]
    #
    def initialize(refresh: true, validate: false, filters: {})
      if refresh
        refresh_list!(filters)
      else
        @proxies = []
      end

      cleanup! if validate
    end

    # Update current proxy list using configured providers.
    #
    # @param filters [Hash] providers filters
    #
    def refresh_list!(filters = nil)
      @proxies = []

      threads = []
      lock = Mutex.new

      ProxyFetcher.config.providers.each do |provider_name|
        threads << Thread.new do
          provider = ProxyFetcher::Configuration.providers_registry.class_for(provider_name)
          provider_filters = filters && filters.fetch(provider_name.to_sym, filters)
          provider_proxies = provider.fetch_proxies!(provider_filters)

          lock.synchronize do
            @proxies.concat(provider_proxies)
          end
        end
      end

      threads.each(&:join)

      @proxies
    end

    alias fetch! refresh_list!

    # Pop just first proxy (and back it to the end of the proxy list).
    #
    # @return [Proxy]
    #   proxy object from the list
    #
    def get
      return if @proxies.empty?

      first_proxy = @proxies.shift
      @proxies << first_proxy

      first_proxy
    end

    alias pop get

    # Pop first valid proxy (and back it to the end of the proxy list)
    # Invalid proxies will be removed from the list
    #
    # @return [Proxy]
    #   proxy object from the list
    #
    def get!
      index = proxies.find_index(&:connectable?)
      return if index.nil?

      proxy = proxies.delete_at(index)
      tail = proxies[index..-1]

      @proxies = tail << proxy

      proxy
    end

    alias pop! get!

    # Clean current proxy list from dead proxies (that doesn't respond by timeout)
    #
    # @return [Array<ProxyFetcher::Proxy>]
    #   list of valid proxies
    def cleanup!
      valid_proxies = ProxyListValidator.new(@proxies).validate
      @proxies &= valid_proxies
    end

    alias validate! cleanup!

    # Returns random proxy
    #
    # @return [Proxy]
    #   random proxy from the loaded list
    #
    def random_proxy
      proxies.sample
    end

    alias random random_proxy

    # Returns array of proxy URLs (just schema + host + port)
    #
    # @return [Array<String>]
    #   collection of proxies
    #
    def raw_proxies
      proxies.map(&:url)
    end

    # @private No need to put all the attr_readers to the output
    def inspect
      to_s
    end
  end
end
