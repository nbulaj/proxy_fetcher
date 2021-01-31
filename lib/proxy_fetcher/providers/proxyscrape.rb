# frozen_string_literal: true

require "csv"

module ProxyFetcher
  module Providers
    # FreeProxyList provider class.
    class Proxyscrape < Base
      # Provider URL to fetch proxy list
      def provider_url
        "https://api.proxyscrape.com/v2/"
      end

      def provider_params
        {
          request: "getproxies",
          timeout: 1_000,
        }
      end

      def pages_count
        2
      end

      def first_page_number
        0
      end

      def page_param_name
        'protocol'
      end

      def page_param_values
        [
          'http',
          'socks4',
          'socks5',
        ]
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
      def to_proxy(node, filters)
        addr, port = node.split(":")

        ProxyFetcher::Proxy.new.tap do |proxy|
          proxy.addr = addr
          proxy.port = Integer(port)
          proxy.country = "Unknown"
          proxy.anonymity = "Unknown"
          proxy.type = parse_type(filters[page_param_name])
        end
      end

      # Parses String to extract proxy type.
      #
      # @param type [String]
      #   String from filters.
      #
      # @return [String]
      #   Proxy type
      #
      def parse_type(type)
        return ProxyFetcher::Proxy::HTTP   if type&.casecmp("http")&.zero?
        return ProxyFetcher::Proxy::HTTPS  if type&.casecmp("https")&.zero?
        return ProxyFetcher::Proxy::SOCKS4 if type&.casecmp("socks4")&.zero?
        return ProxyFetcher::Proxy::SOCKS5 if type&.casecmp("socks5")&.zero?

        "Unknown"
      end
    end

    ProxyFetcher::Configuration.register_provider(:proxyscrape, Proxyscrape)
  end
end
