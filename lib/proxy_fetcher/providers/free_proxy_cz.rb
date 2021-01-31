# frozen_string_literal: true

require "base64"

module ProxyFetcher
  module Providers
    # FreeProxyCz provider class.
    class FreeProxyCz < Base
      # Provider URL to fetch proxy list
      def provider_url
        "http://free-proxy.cz/en/"
      end

      # [NOTE] Doesn't support filtering
      def xpath
        '//table[@id="proxy_list"]/tbody/tr'
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
          addr = parse_addr(html_node)

          next if addr.nil?

          proxy.addr = addr
          proxy.port = Integer(html_node.content_at("td[2]"))

          proxy.type = parse_type(html_node)
          proxy.country = html_node.content_at("td[4]")
          proxy.anonymity = html_node.content_at("td[7]")
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
      def parse_addr(html_node)
        element = html_node.at_css("td.left script")

        return nil if element.node.nil?

        ::Base64.decode64(html_node.at_css("td.left script").html.match(/"(.+)"/)[1])
      end

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

    ProxyFetcher::Configuration.register_provider(:free_proxy_cz, FreeProxyCz)
  end
end
