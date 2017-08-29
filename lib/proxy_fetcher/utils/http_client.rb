module ProxyFetcher
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
