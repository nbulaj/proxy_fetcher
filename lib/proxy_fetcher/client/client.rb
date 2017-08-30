module ProxyFetcher
  module Client
    # rubocop:disable Metrics/LineLength
    DEFAULT_USER_AGENT = 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36'.freeze

    DEFAULT_HEADERS = {
      'User-Agent' => DEFAULT_USER_AGENT
    }.freeze

    class << self
      def get(url, headers: {}, options: {})
        safe_request_to(url, options.fetch(:max_retries, 1000)) do |proxy|
          opts = options.merge(method: :get, url: url, proxy: proxy, headers: DEFAULT_HEADERS.merge(headers))

          Request.execute(**opts)
        end
      end

      def post(url, payload, headers: {}, options: {})
        safe_request_to(url, options.fetch(:max_retries, 1000)) do |proxy|
          opts = options.merge(method: :post, url: url, payload: payload, proxy: proxy, headers: DEFAULT_HEADERS.merge(headers))

          Request.execute(**opts)
        end
      end

      def delete(url, headers: {}, options: {})
        safe_request_to(url, options.fetch(:max_retries, 1000)) do |proxy|
          opts = options.merge(method: :delete, url: url, proxy: proxy, headers: DEFAULT_HEADERS.merge(headers))

          Request.execute(**opts)
        end
      end

      def put(url, payload, headers: {}, options: {})
        safe_request_to(url, options.fetch(:max_retries, 1000)) do |proxy|
          opts = options.merge(method: :put, url: url, payload: payload, proxy: proxy, headers: DEFAULT_HEADERS.merge(headers))

          Request.execute(**opts)
        end
      end

      def patch(url, payload, headers: {}, options: {})
        safe_request_to(url, options.fetch(:max_retries, 1000)) do |proxy|
          opts = options.merge(method: :patch, url: url, payload: payload, proxy: proxy, headers: DEFAULT_HEADERS.merge(headers))

          Request.execute(**opts)
        end
      end

      private

      def safe_request_to(url, max_retries = 1000)
        tries = 1

        begin
          proxy = ProxiesRegistry.find_proxy_for(url)
          yield(proxy)
        rescue ProxyFetcher::Error
          raise
        rescue StandardError
          raise ProxyFetcher::Exceptions::MaximumRetriesReached if max_retries && tries >= max_retries

          ProxiesRegistry.invalidate_proxy!(proxy)
          tries += 1

          retry
        end
      end
    end
  end
end
