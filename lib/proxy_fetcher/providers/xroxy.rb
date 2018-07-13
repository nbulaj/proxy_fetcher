# frozen_string_literal: true

module ProxyFetcher
  module Providers
    # XRoxy provider class.
    class XRoxy < Base
      # Provider URL to fetch proxy list
      PROVIDER_URL = 'https://www.xroxy.com/proxylist.php'.freeze

      # Fetches HTML content by sending HTTP request to the provider URL and
      # parses the document (built as abstract <code>ProxyFetcher::Document</code>)
      # to return all the proxy entries (HTML nodes).
      #
      # @return [Array<ProxyFetcher::Document::Node>]
      #   Collection of extracted HTML nodes with full proxy info
      #
      def load_proxy_list(filters = { type: 'All_http' })
        doc = load_document(PROVIDER_URL, filters)
        doc.xpath('//div[@id="content"]/table[1]/tr[contains(@class, "row")]')
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
          proxy.addr = html_node.content_at('td[2]')
          proxy.port = Integer(html_node.content_at('td[3]').gsub(/^0+/, ''))
          proxy.anonymity = html_node.content_at('td[4]')
          proxy.country = html_node.content_at('td[6]')
          proxy.response_time = Integer(html_node.content_at('td[7]'))
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
        https = html_node.content_at('td[5]')
        https.casecmp('true').zero? ? ProxyFetcher::Proxy::HTTPS : ProxyFetcher::Proxy::HTTP
      end
    end

    ProxyFetcher::Configuration.register_provider(:xroxy, XRoxy)
  end
end
