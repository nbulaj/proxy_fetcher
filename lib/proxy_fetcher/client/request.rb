# frozen_string_literal: true

module ProxyFetcher
  module Client
    # ProxyFetcher::Client HTTP request abstraction.
    class Request
      # URL encoding HTTP headers.
      URL_ENCODED = {
        'Content-Type' => 'application/x-www-form-urlencoded'
      }.freeze

      # Default SSL options that will be used for connecting to resources
      # the uses secure connection. By default ProxyFetcher wouldn't verify
      # SSL certs.
      DEFAULT_SSL_OPTIONS = {
        verify_mode: OpenSSL::SSL::VERIFY_NONE
      }.freeze

      # @!attribute [r] http
      #   @return [Class] HTTP client
      attr_reader :http

      # @!attribute [r] method
      #   @return [String, Symbol] HTTP request method
      attr_reader :method

      # @!attribute [r] uri
      #   @return [URI] Request URI
      attr_reader :uri

      # @!attribute [r] headers
      #   @return [Hash] HTTP headers
      attr_reader :headers

      # @!attribute [r] timeout
      #   @return [Integer] Request timeout
      attr_reader :timeout

      # @!attribute [r] payload
      #   @return [String, Hash] Request payload
      attr_reader :payload

      # @!attribute [r] proxy
      #   @return [Proxy] Proxy to process the request
      attr_reader :proxy

      # @!attribute [r] max_redirects
      #   @return [Integer] Maximum count of requests (if fails)
      attr_reader :max_redirects

      # @!attribute [r] ssl_options
      #   @return [Hash] SSL options
      attr_reader :ssl_options

      # Initializes a new HTTP request and processes it
      #
      # @return [String]
      #   response body (requested resource content)
      #
      def self.execute(args)
        new(args).execute
      end

      # Initialize new HTTP request
      #
      # @return [Request]
      #
      # @api private
      #
      def initialize(args)
        raise ArgumentError, 'args must be a Hash!' unless args.is_a?(Hash)

        @uri = URI.parse(args.fetch(:url))
        @method = args.fetch(:method).to_s.capitalize
        @headers = (args[:headers] || {}).dup
        @payload = preprocess_payload(args[:payload])
        @timeout = args.fetch(:timeout, ProxyFetcher.config.timeout)
        @ssl_options = args.fetch(:ssl_options, DEFAULT_SSL_OPTIONS)

        @proxy = args.fetch(:proxy)
        @max_redirects = args.fetch(:max_redirects, 10)

        build_http_client
      end

      # Executes HTTP request with defined options.
      #
      # @return [String]
      #   response body (requested resource content)
      #
      def execute
        request = request_class_for(method).new(uri, headers)

        http.start do |connection|
          process_response!(connection.request(request, payload))
        end
      end

      private

      # Converts payload to the required format, so <code>Hash</code>
      # must be a WWW-Form encoded for example.
      #
      def preprocess_payload(payload)
        return if payload.nil?

        if payload.is_a?(Hash)
          headers.merge!(URL_ENCODED)
          URI.encode_www_form(payload)
        else
          payload
        end
      end

      # Builds HTTP client based on stdlib Net::HTTP.
      #
      # @return [Net::HTTP]
      #   HTTP client
      #
      def build_http_client
        @http = Net::HTTP.new(uri.host, uri.port, proxy.addr, proxy.port)

        @http.use_ssl = uri.is_a?(URI::HTTPS)
        @http.verify_mode = ssl_options.fetch(:verify_mode)
        @http.open_timeout = timeout
        @http.read_timeout = timeout
      end

      # Processes HTTP response: checks it status and follows redirect if required.
      # If response returned an error, then throws it.
      #
      # @param http_response [Net::HTTPResponse]
      #   HTTP response object
      #
      # @return [String]
      #   requested resource content
      #
      def process_response!(http_response)
        case http_response
        when Net::HTTPSuccess then http_response.read_body
        when Net::HTTPRedirection then follow_redirection(http_response)
        else
          http_response.error!
        end
      end

      # Follows redirection for response.
      #
      def follow_redirection(http_response)
        raise ProxyFetcher::Exceptions::MaximumRedirectsReached if max_redirects <= 0

        url = http_response.fetch('location')
        url = uri.merge(url).to_s unless url.downcase.start_with?('http')

        Request.execute(method: :get, url: url, proxy: proxy, headers: headers, timeout: timeout, max_redirects: max_redirects - 1)
      end

      # Returns particular Net::HTTP method object
      # for processing required request.
      #
      def request_class_for(method)
        Net::HTTP.const_get(method, false)
      end
    end
  end
end
