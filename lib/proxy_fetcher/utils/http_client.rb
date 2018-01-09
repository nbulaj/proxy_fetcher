# frozen_string_literal: true

module ProxyFetcher
  # Default ProxyFetcher HTTP client used to fetch proxy lists from
  # the different providers. Uses ProxyFetcher configuration options
  # for sending HTTP requests to providers URLs.
  class HTTPClient
    # @!attribute [r] uri
    #   @return [URI] URI
    attr_reader :uri

    # @!attribute [r] http
    #   @return [Net::HTTP] HTTP client
    attr_reader :http

    # Initialize HTTP client instance
    #
    # @return [HTTPClient]
    #
    def initialize(url)
      @uri = URI.parse(url)
      @http = Net::HTTP.new(@uri.host, @uri.port)
      return unless https?

      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    # Fetches resource content by sending HTTP request to it.
    #
    # @return [String]
    #   response body
    #
    def fetch
      request = Net::HTTP::Get.new(@uri.to_s)
      request['Connection'] = 'keep-alive'
      request['User-Agent'] = ProxyFetcher.config.user_agent
      response = @http.request(request)
      response.body
    end

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

    # Checks if URI requires secure connection (HTTPS)
    #
    # @return [Boolean]
    #   true if URI is HTTPS, false otherwise
    #
    def https?
      @uri.is_a?(URI::HTTPS)
    end
  end
end
