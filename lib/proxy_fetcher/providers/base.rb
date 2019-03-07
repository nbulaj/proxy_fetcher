# frozen_string_literal: true

module ProxyFetcher
  module Providers
    # Base class for all the ProxyFetcher providers.
    class Base
      # Loads proxy provider page content, extract proxy list from it
      # and convert every entry to proxy object.
      def fetch_proxies!(filters = {})
        raw_proxies = load_proxy_list(filters)
        proxies = raw_proxies.map { |html_node| build_proxy(html_node) }.compact
        proxies.reject { |proxy| proxy.addr.nil? }
      end

      def provider_url
        raise NotImplementedError, "#{__method__} must be implemented in a descendant class!"
      end

      def provider_method
        :get
      end

      def provider_params
        {}
      end

      def provider_headers
        {}
      end

      # Just synthetic sugar to make it easier to call #fetch_proxies! method.
      def self.fetch_proxies!(*args)
        new.fetch_proxies!(*args)
      end

      protected

      # Loads raw provider HTML with proxies.
      #
      # @return [String]
      #   HTML body
      #
      def load_html(url, filters = {})
        raise ArgumentError, 'filters must be a Hash' if filters && !filters.is_a?(Hash)

        uri = URI.parse(url)
        # TODO: query for post request?
        uri.query = URI.encode_www_form(provider_params.merge(filters)) if filters && filters.any?

        ProxyFetcher.config.http_client.fetch(
          uri.to_s,
          method: provider_method,
          headers: provider_headers,
          params: provider_params
        )
      end

      # Loads provider HTML and parses it with internal document object.
      #
      # @param url [String]
      #   URL to fetch
      #
      # @param filters [Hash]
      #   filters for proxy provider
      #
      # @return [ProxyFetcher::Document]
      #   ProxyFetcher document object
      #
      def load_document(url, filters = {})
        html = load_html(url, filters)
        ProxyFetcher::Document.parse(html)
      end

      def build_proxy(*args)
        to_proxy(*args)
      rescue StandardError => error
        ProxyFetcher.logger.warn(
          "Failed to build Proxy object for #{self.class.name} due to error: #{error.message}"
        )

        nil
      end

      # Fetches HTML content by sending HTTP request to the provider URL and
      # parses the document (built as abstract <code>ProxyFetcher::Document</code>)
      # to return all the proxy entries (HTML nodes).
      #
      # Abstract method. Must be implemented in a descendant class
      #
      # @return [Array<Document::Node>]
      #   list of proxy elements from the providers HTML content
      #
      def load_proxy_list(*)
        raise NotImplementedError, "#{__method__} must be implemented in a descendant class!"
      end

      # Convert HTML element with proxy info to ProxyFetcher::Proxy instance.
      #
      # Abstract method. Must be implemented in a descendant class
      #
      # @return [Proxy]
      #   new proxy object from the HTML node
      #
      def to_proxy(*)
        raise NotImplementedError, "#{__method__} must be implemented in a descendant class!"
      end
    end
  end
end
