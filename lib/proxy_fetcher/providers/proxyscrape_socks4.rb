# frozen_string_literal: true

require 'csv'

module ProxyFetcher
  module Providers
    # FreeProxyList provider class.
    class ProxyscrapeSOCKS4 < Base
      # Provider URL to fetch proxy list
      def provider_url
        "https://api.proxyscrape.com/v2/?request=getproxies&protocol=socks4"
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

        CSV.parse(html, col_sep: "\t").map do |row|
          row.first
        end
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
      def to_proxy(html_node)
        addr, port = html_node.split(":")

        ProxyFetcher::Proxy.new.tap do |proxy|
          proxy.addr = addr
          proxy.port = Integer(port)
          proxy.country = "Unknown"
          proxy.anonymity = "Unknown"
          proxy.type = ProxyFetcher::Proxy::SOCKS4
        end
      end
    end

    ProxyFetcher::Configuration.register_provider(:proxyscrape_socks4, ProxyscrapeSOCKS4)
  end
end
