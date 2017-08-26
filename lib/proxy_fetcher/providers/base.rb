require 'forwardable'

module ProxyFetcher
  module Providers
    class Base
      extend Forwardable

      def_delegators ProxyFetcher::HTML, :clear, :convert_to_int

      attr_reader :proxy

      def fetch_proxies!(filters = {})
        load_proxy_list(filters).map { |html| to_proxy(html) }
      end

      class << self
        def fetch_proxies!(filters = {})
          new.fetch_proxies!(filters)
        end
      end

      protected

      # Loads HTML document with Nokogiri by the URL combined with custom filters
      def load_document(url, filters = {})
        raise ArgumentError, 'filters must be a Hash' if filters && !filters.is_a?(Hash)

        uri = URI.parse(url)
        uri.query = URI.encode_www_form(filters) if filters && filters.any?

        Nokogiri::HTML(ProxyFetcher.config.http_client.fetch(uri.to_s))
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
      def parse_element(parent, selector, method = :at_xpath)
        clear(parent.public_send(method, selector).content)
      end
    end
  end
end
