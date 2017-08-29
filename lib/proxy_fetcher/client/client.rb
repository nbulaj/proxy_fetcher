module ProxyFetcher
  class Client
    MaximumRetriesReached = Class.new(StandardError)

    class << self
      # rubocop:disable Metrics/LineLength
      DEFAULT_USER_AGENT = 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36'.freeze

      DEFAULT_HEADERS = {
        'User-Agent': DEFAULT_USER_AGENT
      }.freeze

      def get(url, headers: {})
        safe_request_to(url) do |proxy|
          Request.execute(method: :get, url: url, proxy: proxy, headers: DEFAULT_HEADERS.merge(headers))
        end
      end

      private

      def safe_request_to(url, max_retries: 1000)
        tries = 1

        begin
          proxy = find_proxy_for(url)
          yield(proxy)
        rescue StandardError
          raise MaximumRetriesReached, "maximum retries count reached (#{max_retries})" if tries >= max_retries

          remove_proxy!(proxy)
          tries += 1

          retry
        end
      end

      def remove_proxy!(proxy)
        manager.proxies.delete(proxy)
        manager.refresh_list! if manager.proxies.empty?
      end

      def find_proxy_for(url)
        if URI.parse(url).is_a?(URI::HTTPS)
          manager.proxies.detect(&:ssl?)
        else
          manager.random_proxy
        end
      end

      def manager
        manager = Thread.current[:proxy_fetcher_manager]
        return manager unless manager.nil?

        Thread.current[:proxy_fetcher_manager] = ProxyFetcher::Manager.new
      end
    end
  end
end
