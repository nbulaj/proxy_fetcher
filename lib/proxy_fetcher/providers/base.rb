require 'forwardable'

module ProxyFetcher
  module Providers
    class Base
      extend Forwardable

      def_delegators ProxyFetcher::HTML, :clear, :convert_to_int

      PROXY_TYPES = [
        HTTP = 'HTTP'.freeze,
        HTTPS = 'HTTPS'.freeze
      ].freeze

      attr_reader :proxy

      def fetch_proxies!
        load_proxy_list.map { |html| to_proxy(html) }
      end

      class << self
        def fetch_proxies!
          new.fetch_proxies!
        end
      end

      protected

      # Get HTML from the requested URL
      def load_html(url)
        ProxyFetcher.config.http_client.fetch(url)
      end

      # Get HTML elements with proxy info
      def load_proxy_list(*)
        raise NotImplementedError, "#{__method__} must be implemented in a descendant class!"
      end

      # Convert HTML element with proxy info to ProxyFetcher::Proxy instance
      def to_proxy(*)
        raise NotImplementedError, "#{__method__} must be implemented in a descendant class!"
      end

      # Return normalized HTML element content by selector
      def parse_element(element, selector, method = :at_xpath)
        clear(element.public_send(method, selector).content)
      end
    end
  end
end
