module ProxyFetcher
  class Manager
    attr_reader :proxies

    # refresh: true - load proxy list from the remote server on initialization
    # refresh: false - just initialize the class, proxy list will be empty ([])
    def initialize(refresh: true)
      if refresh
        refresh_list!
      else
        @proxies = []
      end
    end

    # Update current proxy list from the provider
    def refresh_list!
      @proxies = ProxyFetcher.config.provider.fetch_proxies!
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

    # Clean current proxy list from dead proxies (doesn't respond by timeout)
    def cleanup!
      proxies.keep_if(&:connectable?)
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
