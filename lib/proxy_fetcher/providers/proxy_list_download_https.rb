# frozen_string_literal: true

require "csv"

module ProxyFetcher
  module Providers
    # FreeProxyList provider class.
    class ProxyListDownloadHTTPS < Base
      # Provider URL to fetch proxy list
      def provider_url
        "https://www.proxy-list.download/api/v1/get?type=https"
      end

      # Loads provider HTML and parses it with internal document object.
      #
      # @param url [String]
      #   URL to fetch
      #
      # @param filters [Hash]
      #   filters for proxy provider
      #
      # @return [Array]
      #   Collection of extracted proxies with ports
      #
      def load_document(url, filters = {})
        html = load_html(url, filters)

        CSV.parse(html, col_sep: "\t").map(&:first)
      end

      # Fetches HTML content by sending HTTP request to the provider URL and
      # parses the txt document to return all the proxy entries (ip addresses
      # and ports).
      #
      # @return [Array]
      #   Collection of extracted proxies with ports
      #
      def load_proxy_list(filters = {})
        load_document(provider_url, filters)
      end

      # Converts String to <code>ProxyFetcher::Proxy</code> object.
      #
      # @param node [String]
      #   String
      #
      # @return [ProxyFetcher::Proxy]
      #   Proxy object
      #
      def to_proxy(node)
        addr, port = node.split(":")

        ProxyFetcher::Proxy.new.tap do |proxy|
          proxy.addr = addr
          proxy.port = Integer(port)
          proxy.country = "Unknown"
          proxy.anonymity = "Unknown"
          proxy.type = ProxyFetcher::Proxy::HTTPS
        end
      end
    end

    ProxyFetcher::Configuration.register_provider(:proxy_list_download_https, ProxyListDownloadHTTPS)
  end
end
