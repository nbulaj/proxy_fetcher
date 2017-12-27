module ProxyFetcher
  module Providers
    # Base class for all the ProxyFetcher providers.
    class Base
      # Loads proxy provider page content, extract proxy list from it
      # and convert every entry to proxy object.
      def fetch_proxies!(filters = {})
        load_proxy_list(filters).map { |html| to_proxy(html) }
      end

      class << self
        # Just synthetic sugar to make it easier to call #fetch_proxies! method.
        def fetch_proxies!(*args)
          new.fetch_proxies!(*args)
        end
      end

      protected

      # Loads HTML document with Nokogiri by the URL combined with custom filters
      def load_document(url, filters = {})
        raise ArgumentError, 'filters must be a Hash' unless filters.is_a?(Hash)

        uri = URI.parse(url)
        uri.query = URI.encode_www_form(filters) if filters && filters.any?

        html = ProxyFetcher.config.http_client.fetch(uri.to_s)
        ProxyFetcher::Document.parse(html)
      end

      # Fetches HTML content by sending HTTP request to the provider URL and
      # parses the document (built as abstract <code>ProxyFetcher::Document</code>)
      # to return all the proxy entries (HTML nodes).
      #
      # Abstract method.
      #
      def load_proxy_list(*)
        raise NotImplementedError, "#{__method__} must be implemented in a descendant class!"
      end

      # Convert HTML element with proxy info to ProxyFetcher::Proxy instance
      def to_proxy(*)
        raise NotImplementedError, "#{__method__} must be implemented in a descendant class!"
      end
    end
  end
end
