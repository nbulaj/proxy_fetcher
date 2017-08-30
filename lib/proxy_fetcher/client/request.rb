module ProxyFetcher
  module Client
    class Request
      URL_ENCODED = {
        'Content-Type' => 'application/x-www-form-urlencoded'
      }.freeze

      attr_reader :http, :method, :uri, :headers, :timeout,
                  :payload, :proxy, :max_redirects

      def self.execute(args)
        new(args).execute
      end

      def initialize(args)
        raise ArgumentError, 'args must be a Hash!' unless args.is_a?(Hash)

        @uri = URI.parse(args.fetch(:url))
        @method = args.fetch(:method).to_s.capitalize
        @headers = (args[:headers] || {}).dup
        @payload = preprocess_payload(args[:payload])
        @timeout = args.fetch(:timeout, ProxyFetcher.config.timeout)

        @proxy = args.fetch(:proxy)
        @max_redirects = args.fetch(:max_redirects, 10)

        build_http_client
      end

      def execute
        request = request_class_for(method).new(uri, headers)

        http.start do |connection|
          process_response!(connection.request(request, payload))
        end
      end

      private

      def preprocess_payload(payload)
        return if payload.nil?

        if payload.is_a?(Hash)
          headers.merge(URL_ENCODED)
          URI.encode_www_form(payload)
        else
          payload
        end
      end

      def build_http_client
        @http = Net::HTTP.new(uri.host, uri.port, proxy.addr, proxy.port)

        @http.use_ssl = uri.is_a?(URI::HTTPS)
        @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        @http.open_timeout = timeout
        @http.read_timeout = timeout
      end

      def process_response!(http_response)
        case http_response
        when Net::HTTPSuccess then http_response.read_body
        when Net::HTTPRedirection then follow_redirection(http_response)
        else
          http_response.error!
        end
      end

      def follow_redirection(http_response)
        raise ProxyFetcher::Exceptions::MaximumRedirectsReached if max_redirects <= 0

        url = http_response.fetch('location')
        url = uri.merge(url).to_s unless url.downcase.start_with?('http')

        Request.execute(method: :get, url: url, proxy: proxy, headers: headers, timeout: timeout, max_redirects: max_redirects - 1)
      end

      def request_class_for(method)
        Net::HTTP.const_get(method, false)
      end
    end
  end
end
