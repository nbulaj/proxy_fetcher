module ProxyFetcher
  class Client
    class Request
      attr_reader :http, :method, :uri, :headers, :timeout,
                  :payload, :proxy, :max_redirects

      def self.execute(args)
        new(args).execute
      end

      def initialize(args)
        @uri = URI.parse(args.fetch(:url))
        @method = args.fetch(:method).to_s.capitalize
        @headers = (args[:headers] || {}).dup
        @payload = args[:payload]
        @timeout = args.fetch(:timeout, ProxyFetcher.config.connection_timeout)

        @proxy = args.fetch(:proxy)
        @max_redirects = args.fetch(:max_redirects, 10)

        build_http_client
      end

      def execute
        request = net_http_request_class(method).new(uri, headers)

        @http.start do |http|
          http.request(request, payload)
          # TODO: redirects
=begin
          case response
            when Net::HTTPSuccess     then response.body
            when Net::HTTPRedirection then get(response['location'], headers: headers, options: options, limit: limit - 1)
            else
              response.error!
          end
=end
        end
      end

      def build_http_client
        @http = Net::HTTP.new(uri.host, @uri.port, @proxy.addr, @proxy.port)

        @http.use_ssl = @uri.is_a?(URI::HTTPS)
        @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        @http.open_timeout = @timeout
        @http.read_timeout = @timeout
      end

      def net_http_request_class(method)
        Net::HTTP.const_get(method, false)
      end
    end
  end
end
