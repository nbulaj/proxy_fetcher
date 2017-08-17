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
        def parse_entry(entry, proxy_instance)
          new(proxy_instance).parse!(entry)
        end

        # Get HTML from the requested URL
        def load_html(url)
          ProxyFetcher.config.http_client.fetch(url)
        end
      end
    end
  end
end
