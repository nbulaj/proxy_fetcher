# frozen_string_literal: true

module ProxyFetcher
  module Providers
    # Scrapingant provider class.
    class Scrapingant < Base
      # Provider URL to fetch proxy list
      def provider_url
        "https://scrapingant.com/free-proxies/"
      end

      # [NOTE] Doesn't support filtering
      def xpath
        '//table[contains(@class, "proxies-table")]/tr[count(td)>2]'
      end

      # Converts HTML node (entry of N tags) to <code>ProxyFetcher::Proxy</code>
      # object.
      #
      # @param html_node [Object]
      #   HTML node from the <code>ProxyFetcher::Document</code> DOM model.
      #
      # @return [ProxyFetcher::Proxy]
      #   Proxy object
      #
      def to_proxy(html_node)
        ProxyFetcher::Proxy.new.tap do |proxy|
          proxy.addr = html_node.content_at("td[1]")
          proxy.port = Integer(html_node.content_at("td[2]"))

          proxy.type = parse_type(html_node)
          proxy.country = html_node.content_at("td[4]")
          proxy.anonymity = "Unknown"
        end
      end

      private

      # Parses HTML node to extract proxy type.
      #
      # @param html_node [Object]
      #   HTML node from the <code>ProxyFetcher::Document</code> DOM model.
      #
      # @return [String]
      #   Proxy type
      #
      def parse_type(html_node)
        type = html_node.content_at("td[3]")

        return ProxyFetcher::Proxy::HTTP   if type&.casecmp("http")&.zero?
        return ProxyFetcher::Proxy::HTTPS  if type&.casecmp("https")&.zero?
        return ProxyFetcher::Proxy::SOCKS4 if type&.casecmp("socks4")&.zero?
        return ProxyFetcher::Proxy::SOCKS5 if type&.casecmp("socks5")&.zero?

        "Unknown"
      end
    end

    ProxyFetcher::Configuration.register_provider(:scrapingant, Scrapingant)
  end
end
