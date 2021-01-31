# frozen_string_literal: true

module ProxyFetcher
  module Providers
    # FreeProxyListUS provider class.
    class FreeProxyListUS < Base
      # Provider URL to fetch proxy list
      def provider_url
        "https://www.us-proxy.org/"
      end

      # [NOTE] Doesn't support filtering
      def xpath
        '//table[@id="proxylisttable"]/tbody/tr'
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
      def to_proxy(html_node, filters)
        ProxyFetcher::Proxy.new.tap do |proxy|
          proxy.addr = html_node.content_at("td[1]")
          proxy.port = Integer(html_node.content_at("td[2]").gsub(/^0+/, ""))
          proxy.country = html_node.content_at("td[4]")
          proxy.anonymity = html_node.content_at("td[5]")
          proxy.type = parse_type(html_node)
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
        type = html_node.content_at("td[7]")
        type&.casecmp("yes")&.zero? ? ProxyFetcher::Proxy::HTTPS : ProxyFetcher::Proxy::HTTP
      end
    end

    ProxyFetcher::Configuration.register_provider(:free_proxy_list_us, FreeProxyListUS)
  end
end
