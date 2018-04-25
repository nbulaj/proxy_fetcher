# frozen_string_literal: true

module ProxyFetcher
  module Client
    # ProxyFetcher::Client HTTP request abstraction.
    class Request
      # @!attribute [r] http
      #   @return [Object] HTTP client
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
      def initialize(args)
        raise ArgumentError, 'args must be a Hash!' unless args.is_a?(Hash)

        @uri = URI.parse(args.fetch(:url))
        @method = args.fetch(:method).to_s.downcase
        @headers = (args[:headers] || {}).dup
        @payload = args[:payload]
        @timeout = args.fetch(:timeout, ProxyFetcher.config.timeout)
        @ssl_options = args.fetch(:ssl_options, default_ssl_options)

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
        response = begin
          if payload
            payload_type = payload.is_a?(String) ? :body : :form

            http.public_send(method, uri.to_s, payload_type => payload, ssl_context: ssl_options)
          else
            http.public_send(method, uri.to_s, ssl_context: ssl_options)
          end
        rescue HTTP::Redirector::TooManyRedirectsError
          raise ProxyFetcher::Exceptions::MaximumRedirectsReached
        end

        response.body.to_s
      end

      private

      # Builds HTTP client based on stdlib Net::HTTP.
      #
      # @return [Net::HTTP]
      #   HTTP client
      #
      def build_http_client
        @http = HTTP.headers(headers)
                    .timeout(connect: timeout, read: timeout)
                    .follow(max_hops: max_redirects)
      end

      # Default SSL options that will be used for connecting to resources
      # the uses secure connection. By default ProxyFetcher wouldn't verify
      # SSL certs.
      #
      # @return [OpenSSL::SSL::SSLContext] SSL context
      #
      def default_ssl_options
        ssl_ctx = OpenSSL::SSL::SSLContext.new
        ssl_ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
        ssl_ctx
      end
    end
  end
end
