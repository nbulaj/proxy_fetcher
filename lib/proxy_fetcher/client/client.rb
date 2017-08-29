module ProxyFetcher
  class Client
    MaximumRetriesReached = Class.new(StandardError)

    class << self
      # rubocop:disable Metrics/LineLength
      DEFAULT_USER_AGENT = 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36'.freeze

      DEFAULT_HEADERS = {
        'User-Agent': DEFAULT_USER_AGENT
      }.freeze

      def get(url, headers: {}, options: {}, limit: 10)
        safe_request_to(url) do |proxy|
          http = build_http_client(url, proxy, options)

          request = Net::HTTP::Get.new(URI.parse(url), DEFAULT_HEADERS.merge(headers))
          response = http.request(request)
          response.body

          case response
          when Net::HTTPSuccess     then response.body
          when Net::HTTPRedirection then get(response['location'], headers: headers, options: options, limit: limit - 1)
          else
            response.error!
          end
        end
      end

      def post(url, payload, headers = {}, options: {})
        safe_request_to(url) do |proxy|
          http = build_http_client(url, proxy, options)

          request = Net::HTTP::Post.new(URI.parse(url), DEFAULT_HEADERS.merge(headers))
          request.set_form_data(payload)
          response = http.request(request)
          response.body
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

      def build_http_client(url, proxy, options = {})
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port, proxy.addr, proxy.port)

        http.read_timeout = options.fetch(:read_timeout, ProxyFetcher.config.connection_timeout)
        http.open_timeout = options.fetch(:open_timeout, ProxyFetcher.config.connection_timeout)

        if uri.is_a?(URI::HTTPS)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        http
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
