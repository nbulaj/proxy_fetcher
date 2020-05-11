# frozen_string_literal: true

module ProxyFetcher
  module Providers
    # FreeProxyList provider class.
    class Proxypedia < Base
      # Provider URL to fetch proxy list
      def provider_url
        "https://proxypedia.org"
      end

      # [NOTE] Doesn't support filtering
      def xpath
        "//main/ul/li[position()>1]"
      end

      # Converts HTML node (entry of N tags) to <code>ProxyFetcher::Proxy</code>
      # object.]
      #
      # @param html_node [Object]
      #   HTML node from the <code>ProxyFetcher::Document</code> DOM model.
      #
      # @return [ProxyFetcher::Proxy]
      #   Proxy object
      #
      def to_proxy(html_node)
        addr, port = html_node.content_at("a").to_s.split(":")

        ProxyFetcher::Proxy.new.tap do |proxy|
          proxy.addr = addr
          proxy.port = Integer(port)
          proxy.country = parse_country(html_node)
          proxy.anonymity = "Unknown"
          proxy.type = ProxyFetcher::Proxy::HTTP
        end
      end

      private

      def parse_country(html_node)
        text = html_node.content.to_s
        text[/\((.+?)\)/, 1] || "Unknown"
      end
    end

    ProxyFetcher::Configuration.register_provider(:proxypedia, Proxypedia)
  end
end
