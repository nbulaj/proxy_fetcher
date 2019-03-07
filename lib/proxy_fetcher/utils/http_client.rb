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
    def self.fetch(*args)
      new(*args).fetch
    end

    # Initialize HTTP client instance
    #
    # @return [HTTPClient]
    #
    def initialize(url, method: :get, params: {}, headers: {})
      @url = url.to_s
      @method = method
      @params = params
      @headers = headers

      @http = HTTP.headers(default_headers.merge(headers)).timeout(connect: timeout, read: timeout)
      @timeout = ProxyFetcher.config.provider_proxies_load_timeout

      @ssl_ctx = OpenSSL::SSL::SSLContext.new
      @ssl_ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    # Fetches resource content by sending HTTP request to it.
    #
    # @return [String]
    #   response body
    #
    def fetch
      # TODO: must be more generic
      response = if method == :post
                   http.post(url, form: params, ssl_context: ssl_ctx)
                 else
                   http.get(url, ssl_context: ssl_ctx)
                 end

      response.body.to_s
    rescue StandardError => error
      ProxyFetcher.logger.warn("Failed to load proxy list for #{url} (#{error.message})")
      ''
    end

    protected

    # Default HTTP client headers
    #
    # @return [Hash]
    #   hash of HTTP headers
    #
    def default_headers
      {
        'User-Agent' => ProxyFetcher.config.user_agent
      }
    end
  end
end
