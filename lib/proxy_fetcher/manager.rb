# frozen_string_literal: true

module ProxyFetcher
  # ProxyFetcher Manager class for interacting with proxy lists from various providers.
  class Manager
    attr_reader :proxies

    # refresh: true - load proxy list from the remote server on initialization
    # refresh: false - just initialize the class, proxy list will be empty ([])
    def initialize(refresh: true, validate: false, filters: {})
      if refresh
        refresh_list!(filters)
      else
        @proxies = []
      end

      cleanup! if validate
    end

    # Update current proxy list from the provider
    def refresh_list!(filters = nil)
      @proxies = []

      ProxyFetcher.config.providers.each do |provider_name|
        provider = ProxyFetcher::Configuration.providers_registry.class_for(provider_name)
        provider_filters = filters && filters.fetch(provider_name.to_sym, filters)

        @proxies.concat(provider.fetch_proxies!(provider_filters))
      end
    end

    alias fetch! refresh_list!

    # Pop just first proxy (and back it to the end of the proxy list)
    def get
      return if @proxies.empty?

      first_proxy = @proxies.shift
      @proxies << first_proxy

      first_proxy
    end

    alias pop get

    # Pop first valid proxy (and back it to the end of the proxy list)
    # Invalid proxies will be removed from the list
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
    def cleanup!
      lock = Mutex.new

      proxies.dup.each_slice(ProxyFetcher.config.pool_size) do |proxy_group|
        threads = proxy_group.map do |group_proxy|
          Thread.new(group_proxy, proxies) do |proxy, proxies|
            lock.synchronize { proxies.delete(proxy) } unless proxy.connectable?
          end
        end

        threads.each(&:join)
      end

      @proxies
    end

    alias validate! cleanup!

    # Return random proxy
    def random_proxy
      proxies.sample
    end

    alias random random_proxy

    # Returns array of proxy URLs (just schema + host + port)
    def raw_proxies
      proxies.map(&:url)
    end

    # No need to put all the attr_readers
    def inspect
      to_s
    end
  end
end
