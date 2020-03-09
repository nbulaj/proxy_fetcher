# frozen_string_literal: true

require "json"

module ProxyFetcher
  module Providers
    # GatherProxy provider class.
    class GatherProxy < Base
      # Provider URL to fetch proxy list
      def provider_url
        "https://proxygather.com"
      end

      def xpath
        '//div[@class="proxy-list"]/table/script'
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
        json = parse_json(html_node)

        ProxyFetcher::Proxy.new.tap do |proxy|
          proxy.addr = json["PROXY_IP"]
          proxy.port = json["PROXY_PORT"].to_i(16)
          proxy.anonymity = json["PROXY_TYPE"]
          proxy.country = json["PROXY_COUNTRY"]
          proxy.response_time = json["PROXY_TIME"].to_i
          proxy.type = ProxyFetcher::Proxy::HTTP
        end
      end

      private

      def parse_json(html_node)
        javascript = html_node.content[/{.+}/im]
        JSON.parse(javascript)
      end
    end

    ProxyFetcher::Configuration.register_provider(:gather_proxy, GatherProxy)
  end
end
