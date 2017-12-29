# frozen_string_literal: true

module ProxyFetcher
  # ProxyFetcher HTTP client that encapsulates all the logic for sending
  # HTTP(S) requests using proxies, automatically fetched and validated by the gem.
  module Client
    class << self
      # Sends HTTP GET request.
      #
      # @param url [String]
      #   Requested URL
      #
      # @param headers [Hash]
      #   HTTP headers that will be used in the request
      #
      # @param options [Hash]
      #   Additional options used by <code>ProxyFetcher::Client</code>
      #
      # @return [String]
      #   HTML body from the URL.
      #
      def get(url, headers: {}, options: {})
        request_without_payload(:get, url, headers, options)
      end

      # Sends HTTP HEAD request.
      #
      # @param url [String]
      #   Requested URL
      #
      # @param headers [Hash]
      #   HTTP headers that will be used in the request
      #
      # @param options [Hash]
      #   Additional options used by <code>ProxyFetcher::Client</code>
      #
      # @return [String]
      #   HTML body from the URL.
      #
      def head(url, headers: {}, options: {})
        request_without_payload(:head, url, headers, options)
      end

      # Sends HTTP POST request.
      #
      # @param url [String]
      #   Requested URL
      #
      # @param payload [String, Hash]
      #   HTTP payload
      #
      # @param headers [Hash]
      #   HTTP headers that will be used in the request
      #
      # @param options [Hash]
      #   Additional options used by <code>ProxyFetcher::Client</code>
      #
      # @return [String]
      #   HTML body from the URL.
      #
      def post(url, payload, headers: {}, options: {})
        request_with_payload(:post, url, payload, headers, options)
      end

      # Sends HTTP DELETE request.
      #
      # @param url [String]
      #   Requested URL
      #
      # @param headers [Hash]
      #   HTTP headers that will be used in the request
      #
      # @param options [Hash]
      #   Additional options used by <code>ProxyFetcher::Client</code>
      #
      # @return [String]
      #   HTML body from the URL.
      #
      def delete(url, headers: {}, options: {})
        request_without_payload(:delete, url, headers, options)
      end

      # Sends HTTP PUT request.
      #
      # @param url [String]
      #   Requested URL
      #
      # @param payload [String, Hash]
      #   HTTP payload
      #
      # @param headers [Hash]
      #   HTTP headers that will be used in the request
      #
      # @param options [Hash]
      #   Additional options used by <code>ProxyFetcher::Client</code>
      #
      # @return [String]
      #   HTML body from the URL.
      #
      def put(url, payload, headers: {}, options: {})
        request_with_payload(:put, url, payload, headers, options)
      end

      # Sends HTTP PATCH request.
      #
      # @param url [String]
      #   Requested URL
      #
      # @param payload [String, Hash]
      #   HTTP payload
      #
      # @param headers [Hash]
      #   HTTP headers that will be used in the request
      #
      # @param options [Hash]
      #   Additional options used by <code>ProxyFetcher::Client</code>
      #
      # @return [String]
      #   HTML body from the URL.
      #
      def patch(url, payload, headers: {}, options: {})
        request_with_payload(:patch, url, payload, headers, options)
      end

      private

      # Executes HTTP request with user payload.
      #
      def request_with_payload(method, url, payload, headers, options)
        safe_request_to(url, options.fetch(:max_retries, 1000)) do |proxy|
          opts = options.merge(url: url, payload: payload, proxy: proxy, headers: default_headers.merge(headers))

          Request.execute(method: method, **opts)
        end
      end

      # Executes HTTP request without user payload.
      #
      def request_without_payload(method, url, headers, options)
        safe_request_to(url, options.fetch(:max_retries, 1000)) do |proxy|
          opts = options.merge(url: url, proxy: proxy, headers: default_headers.merge(headers))

          Request.execute(method: method, **opts)
        end
      end

      # Default ProxyFetcher::Client http headers. Uses some options
      # from the configuration object, such as User-Agent string.
      #
      # @return [Hash]
      #   headers
      #
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
