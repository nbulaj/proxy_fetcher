# frozen_string_literal: true

module ProxyFetcher
  # Default ProxyFetcher HTTP client used to fetch proxy lists from
  # the different providers. Uses ProxyFetcher configuration options
  # for sending HTTP requests to providers URLs.
  class HTTPClient
    # @!attribute [r] url
    #   @return [String] URL
    attr_reader :url

    # @!attribute [r] HTTP method
    #   @return [String] HTTP method verb
    attr_reader :method

    # @!attribute [r] HTTP params
    #   @return [Hash] params
    attr_reader :params

    # @!attribute [r] HTTP headers
    #   @return [Hash] headers
    attr_reader :headers

    # @!attribute [r] http
    #   @return [Net::HTTP] HTTP client
    attr_reader :http

    # @!attribute [r] ssl_ctx
    #   @return [OpenSSL::SSL::SSLContext] SSL context
    attr_reader :ssl_ctx

    # @!attribute [r] timeout
    #   @return [Integer] Request timeout
    attr_reader :timeout

    # Fetches resource content by sending HTTP request to it.
    # Synthetic sugar to simplify URIes fetching.
    #
    # @param url [String] URL
    #
    # @return [String]
    #   resource content
    #
    def self.fetch(*args, **kwargs, &block)
      new(*args, **kwargs, &block).fetch
    end

    # Initialize HTTP client instance
    #
    # @return [HTTPClient]
    #
    def initialize(url, method: :get, params: {}, headers: {})
      @url = url.to_s
      @method = method.to_sym
      @params = params
      @headers = headers

      unless HTTP::Request::METHODS.include?(@method)
        raise ArgumentError, "'#{@method}' is a wrong HTTP method name"
      end

      @timeout = ProxyFetcher.config.provider_proxies_load_timeout
      @http = build_http_engine
      @ssl_ctx = build_ssl_context
    end

    # Fetches resource content by sending HTTP request to it.
    #
    # @return [String]
    #   response body
    #
    def fetch(**options)
      response = perform_http_request
      return response if options.fetch(:raw, false)

      response.body.to_s
    rescue StandardError => e
      ProxyFetcher.config.logger.warn("Failed to process request to #{url} (#{e.message})")
      ""
    end

    protected

    def build_ssl_context
      OpenSSL::SSL::SSLContext.new.tap do |context|
        context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    def build_http_engine
      HTTP.headers(default_headers.merge(headers)).timeout(connect: timeout, read: timeout)
    end

    def perform_http_request(http_method: method, http_params: params)
      http.public_send(
        http_method,
        url,
        form: http_params,
        ssl_context: ssl_ctx
      )
    end

    # Default HTTP client headers
    #
    # @return [Hash]
    #   hash of HTTP headers
    #
    def default_headers
      {
        "User-Agent" => ProxyFetcher.config.user_agent
      }
    end
  end
end
