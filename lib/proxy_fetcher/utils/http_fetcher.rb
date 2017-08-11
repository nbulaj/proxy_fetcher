module ProxyFetcher
  class HTTPClient
    attr_reader :http

    def initialize(url)
      @uri = URI.parse(url)
      @http = Net::HTTP.new(@uri.host, @uri.port)
      @http.use_ssl = true if @uri.scheme.downcase == 'https'
    end

    def fetch
      request = Net::HTTP::Get.new(@uri.to_s)
      request['Connection'] = 'keep-alive'
      response = @http.request(request)
      response.body
    end

    class << self
      def fetch(url)
        new(url).fetch
      end
    end
  end
end
