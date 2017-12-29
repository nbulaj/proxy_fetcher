# frozen_string_literal: true

module ProxyFetcher
  module Client
    class ProxiesRegistry
      class << self
        # Removes proxy from the list of the current proxy manager
        # instance. If no more proxy available, refreshes the list.
        #
        # @param proxy [ProxyFetcher::Proxy]
        #   proxy object to remove
        #
        def invalidate_proxy!(proxy)
          manager.proxies.delete(proxy)
          manager.refresh_list! if manager.proxies.empty?
        end

        # Searches for valid proxy or required type (HTTP or secure)
        # for requested URL. If no proxy found, than it refreshes proxy list
        # and tries again.
        #
        # @param url [String]
        #   URL to process with proxy
        #
        # @return [ProxyFetcher::Proxy]
        #   gems proxy object
        #
        def find_proxy_for(url)
          proxy = if URI.parse(url).is_a?(URI::HTTPS)
                    manager.proxies.detect(&:ssl?)
                  else
                    manager.get
                  end

          return proxy unless proxy.nil?

          manager.refresh_list!
          find_proxy_for(url)
        end

        # Instantiate or returns <code>ProxyFetcher::Manager</code> instance
        # for current <code>Thread</code>.
        #
        # @return [ProxyFetcher::Manager]
        #   ProxyFetcher manager class
        #
        def manager
          manager = Thread.current[:proxy_fetcher_manager]
          return manager unless manager.nil?

          Thread.current[:proxy_fetcher_manager] = ProxyFetcher::Manager.new
        end
      end
    end
  end
end
