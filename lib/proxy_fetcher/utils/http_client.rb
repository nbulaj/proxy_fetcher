# frozen_string_literal: true

module ProxyFetcher
  # Default ProxyFetcher HTTP client used to fetch proxy lists from
  # the different providers. Uses ProxyFetcher configuration options
  # for sending HTTP requests to providers URLs.
  class HTTPClient
    # @!attribute [r] url
    #   @return [String] URL
    attr_reader :url

    # @!attribute [r] http
    #   @return [Net::HTTP] HTTP client
    attr_reader :http

    # @!attribute [r] ssl_ctx
    #   @return [OpenSSL::SSL::SSLContext] SSL context
    attr_reader :ssl_ctx

    # Fetches resource content by sending HTTP request to it.
    # Synthetic sugar to simplify URIes fetching.
    #
    # @param url [String] URL
    #
    # @return [String]
    #   resource content
    #
    def self.fetch(url)
      new(url).fetch
    end

    # Initialize HTTP client instance
    #
    # @return [HTTPClient]
    #
    def initialize(url)
      @url = url.to_s
      @http = HTTP.headers(default_headers)

      @ssl_ctx = OpenSSL::SSL::SSLContext.new
      @ssl_ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    # Fetches resource content by sending HTTP request to it.
    #
    # @return [String]
    #   response body
    #
    def fetch
      @http.get(url, ssl_context: ssl_ctx).body.to_s
    rescue StandardError
      ProxyFetcher.logger.warn("Failed to load proxy list for #{url}")
      String.new
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
