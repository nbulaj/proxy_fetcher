# frozen_string_literal: true

require "json"

module ProxyFetcher
  module Providers
    # MTPro provider class.
    class MTPro < Base
      # Provider URL to fetch proxy list
      def provider_url
        "https://mtpro.xyz/api/?type=socks"
      end

      def load_proxy_list(filters = {})
        html = load_html(provider_url, filters)
        JSON.parse(html)
      rescue JSON::ParserError
        []
      end

      # Converts HTML node (entry of N tags) to <code>ProxyFetcher::Proxy</code>
      # object.
      #
      # @param node [Object]
      #   HTML node from the <code>ProxyFetcher::Document</code> DOM model.
      #
      # @return [ProxyFetcher::Proxy]
      #   Proxy object
      #
      def to_proxy(node)
        ProxyFetcher::Proxy.new.tap do |proxy|
          proxy.addr = node["ip"]
          proxy.port = Integer(node["port"])
          proxy.country = node["country"]
          proxy.anonymity = "Unknown"
          proxy.type = ProxyFetcher::Proxy::SOCKS5
        end
      end
    end

    ProxyFetcher::Configuration.register_provider(:mtpro, MTPro)
  end
end
