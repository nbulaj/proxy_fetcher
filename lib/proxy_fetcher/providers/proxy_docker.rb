# frozen_string_literal: true

module ProxyFetcher
  module Providers
    # ProxyDocker provider class.
    class ProxyDocker < Base
      # Provider URL to fetch proxy list
      PROVIDER_URL = 'https://www.proxydocker.com/en/proxylist/'.freeze

      # Fetches HTML content by sending HTTP request to the provider URL and
      # parses the document (built as abstract <code>ProxyFetcher::Document</code>)
      # to return all the proxy entries (HTML nodes).
      #
      # @return [Array<ProxyFetcher::Document::Node>]
      #   Collection of extracted HTML nodes with full proxy info
      #
      # [NOTE] Doesn't support direct filters
      def load_proxy_list(*)
        doc = load_document(PROVIDER_URL, {})
        doc.xpath('//table[contains(@class, "table")]/tr[(not(@id="proxy-table-header")) and (count(td)>2)]')
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
          uri = URI("//#{html_node.content_at('td[1]')}")
          proxy.addr = uri.host
          proxy.port = uri.port

          proxy.type = html_node.content_at('td[2]')
          proxy.anonymity = html_node.content_at('td[3]')
          proxy.country = html_node.content_at('td[5]')
        end
      end
    end

    ProxyFetcher::Configuration.register_provider(:proxy_docker, ProxyDocker)
  end
end
