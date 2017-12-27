module ProxyFetcher
  # Default ProxyFetcher HTTP client used to fetch proxy lists from
  # the different providers. Uses ProxyFetcher configuration options
  # for sending HTTP requests to providers URLs.
  class HTTPClient
    attr_reader :uri, :http

    def initialize(url)
      @uri = URI.parse(url)
      @http = Net::HTTP.new(@uri.host, @uri.port)
      return unless https?

      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    def fetch
      request = Net::HTTP::Get.new(@uri.to_s)
      request['Connection'] = 'keep-alive'
      request['User-Agent'] = ProxyFetcher.config.user_agent
      response = @http.request(request)
      response.body
    end

    def https?
      @uri.is_a?(URI::HTTPS)
    end

    class << self
      def fetch(url)
        new(url).fetch
      end
    end
  end
end
