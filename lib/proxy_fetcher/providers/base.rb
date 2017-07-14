module ProxyFetcher
  module Providers
    class Base
      attr_reader :proxy

      def initialize(proxy_instance)
        @proxy = proxy_instance
      end

      def set!(name, value)
        @proxy.instance_variable_set(:"@#{name}", value)
      end

      class << self
        # Get HTML from the requested URL
        def load_html(url)
          uri = URI.parse(url)
          http = Net::HTTP.new(uri.host, uri.port)
          response = http.get(uri.request_uri)
          response.body
        end
      end
    end
  end
end
