module ProxyFetcher
  module Client
    class << self
      def get(url, headers: {}, options: {})
        request_without_payload(:get, url, headers, options)
      end

      def head(url, headers: {}, options: {})
        request_without_payload(:head, url, headers, options)
      end

      def post(url, payload, headers: {}, options: {})
        request_with_payload(:post, url, payload, headers, options)
      end

      def delete(url, headers: {}, options: {})
        request_without_payload(:delete, url, headers, options)
      end

      def put(url, payload, headers: {}, options: {})
        request_with_payload(:put, url, payload, headers, options)
      end

      def patch(url, payload, headers: {}, options: {})
        request_with_payload(:patch, url, payload, headers, options)
      end

      private

      def request_with_payload(method, url, payload, headers, options)
        safe_request_to(url, options.fetch(:max_retries, 1000)) do |proxy|
          opts = options.merge(url: url, payload: payload, proxy: proxy, headers: default_headers.merge(headers))

          Request.execute(method: method, **opts)
        end
      end

      def request_without_payload(method, url, headers, options)
        safe_request_to(url, options.fetch(:max_retries, 1000)) do |proxy|
          opts = options.merge(url: url, proxy: proxy, headers: default_headers.merge(headers))

          Request.execute(method: method, **opts)
        end
      end

      def default_headers
        {
          'User-Agent' => ProxyFetcher.config.user_agent
        }
      end

      def safe_request_to(url, max_retries = 1000)
        tries = 0

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
