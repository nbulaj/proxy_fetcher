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

    def connectable?
      @http.open_timeout = ProxyFetcher.config.connection_timeout
      @http.read_timeout = ProxyFetcher.config.connection_timeout

      @http.start { |connection| return true if connection.request_head('/') }

      false
    rescue StandardError
      false
    end

    def https?
      @uri.scheme.casecmp('https').zero?
    end

    class << self
      def fetch(url)
        new(url).fetch
      end

      def connectable?(url)
        new(url).connectable?
      end
    end
  end
end
