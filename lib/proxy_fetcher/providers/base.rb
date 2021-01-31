# frozen_string_literal: true

module ProxyFetcher
  module Providers
    # Base class for all the ProxyFetcher providers.
    class Base
      # Loads proxy provider page content, extract proxy list from it
      # and convert every entry to proxy object.
      def fetch_proxies(filters = {})
        return fetch_raw_proxies(filters) unless pages_count > 1

        proxies = []

        (first_page_number..pages_count).each do |page_number|
          filters = { page_param_name => page_param_values[page_number] || page_number }
          proxies += fetch_raw_proxies(filters)
        end

        proxies
      end

      def fetch_raw_proxies(filters)
        raw_proxies = load_proxy_list(filters)
        proxies = raw_proxies.map { |html_node| build_proxy(html_node, filters) }.compact
        proxies.reject { |proxy| proxy.addr.nil? }
      end

      # For retro-compatibility
      alias fetch_proxies! fetch_proxies

      def provider_url
        raise NotImplementedError, "#{__method__} must be implemented in a descendant class!"
      end

      def provider_method
        :get
      end

      def provider_params
        {}
      end

      # @return [Hash]
      #   Provider headers required to fetch the proxy list
      #
      def provider_headers
        {}
      end

      def pages_count
        1
      end

      def first_page_number
        1
      end

      def page_param_name
        raise NotImplementedError, "#{__method__} must be implemented in a descendant class!"
      end

      def page_param_values
        []
      end

      def xpath
        raise NotImplementedError, "#{__method__} must be implemented in a descendant class!"
      end

      # Just synthetic sugar to make it easier to call #fetch_proxies! method.
      def self.fetch_proxies!(*args)
        new.fetch_proxies!(*args)
      end

      protected

      # Loads raw provider HTML with proxies.
      #
      # @param url [String]
      #   Provider URL
      #
      # @param filters [#to_h]
      #   Provider filters (Hash-like object)
      #
      # @return [String]
      #   HTML body from the response
      #
      def load_html(url, filters = {})
        unless filters.respond_to?(:to_h)
          raise ArgumentError, "filters must be a Hash or respond to #to_h"
        end

        if filters&.any?
          # TODO: query for post request?
          uri = URI.parse(url)
          uri.query = URI.encode_www_form(provider_params.merge(filters.to_h))
          provider_params = {}
          url = uri.to_s
        end

        ProxyFetcher.config.http_client.fetch(
          url,
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

      # Fetches HTML content by sending HTTP request to the provider URL and
      # parses the document (built as abstract <code>ProxyFetcher::Document</code>)
      # to return all the proxy entries (HTML nodes).
      #
      # @return [Array<ProxyFetcher::Document::Node>]
      #   Collection of extracted HTML nodes with full proxy info
      #
      def load_proxy_list(filters = {})
        doc = load_document(provider_url, filters)
        doc.xpath(xpath)
      end

      def build_proxy(*args)
        to_proxy(*args)
      rescue StandardError => e
        ProxyFetcher.logger.warn(
          "Failed to build Proxy for #{self.class.name.split("::").last} " \
          "due to error: #{e.message}"
        )

        nil
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
