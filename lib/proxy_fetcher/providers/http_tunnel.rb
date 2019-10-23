# frozen_string_literal: true

module ProxyFetcher
  module Providers
    # HTTPTunnel provider class.
    class HTTPTunnel < Base
      # Provider URL to fetch proxy list
      def provider_url
        "http://www.httptunnel.ge/ProxyListForFree.aspx"
      end

      def xpath
        '//table[contains(@id, "GridView")]/tr[(count(td)>2)]'
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
          uri = parse_proxy_uri(html_node)
          proxy.addr = uri.host
          proxy.port = uri.port

          proxy.country = parse_country(html_node)
          proxy.anonymity = parse_anonymity(html_node)
          proxy.type = ProxyFetcher::Proxy::HTTP
        end
      end

      private

      # Parses HTML node to extract URI object with proxy host and port.
      #
      # @param html_node [Object]
      #   HTML node from the <code>ProxyFetcher::Document</code> DOM model.
      #
      # @return [URI]
      #   URI object
      #
      def parse_proxy_uri(html_node)
        full_addr = html_node.content_at("td[1]")
        URI.parse("http://#{full_addr}")
      end

      # Parses HTML node to extract proxy country.
      #
      # @param html_node [Object]
      #   HTML node from the <code>ProxyFetcher::Document</code> DOM model.
      #
      # @return [String]
      #   Country code
      #
      def parse_country(html_node)
        html_node.find(".//img").attr("title")
      end

      # Parses HTML node to extract proxy anonymity level.
      #
      # @param html_node [Object]
      #   HTML node from the <code>ProxyFetcher::Document</code> DOM model.
      #
      # @return [String]
      #   Anonymity level
      #
      def parse_anonymity(html_node)
        transparency = html_node.content_at("td[5]").to_sym

        {
          A: "Anonymous",
          E: "Elite",
          T: "Transparent",
          U: "Unknown"
        }.fetch(transparency, "Unknown")
      end
    end

    ProxyFetcher::Configuration.register_provider(:http_tunnel, HTTPTunnel)
  end
end
