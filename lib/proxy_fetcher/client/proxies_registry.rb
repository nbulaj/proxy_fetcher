module ProxyFetcher
  module Client
    class ProxiesRegistry
      class << self
        def invalidate_proxy!(proxy)
          manager.proxies.delete(proxy)
          manager.refresh_list! if manager.proxies.empty?
        end

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

        def manager
          manager = Thread.current[:proxy_fetcher_manager]
          return manager unless manager.nil?

          Thread.current[:proxy_fetcher_manager] = ProxyFetcher::Manager.new
        end
      end
    end
  end
end
