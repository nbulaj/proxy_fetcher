# frozen_string_literal: true

module ProxyFetcher
  module Providers
    # XRoxy provider class.
    class XRoxy < Base
      # Provider URL to fetch proxy list
      def provider_url
        'https://www.xroxy.com/free-proxy-lists/'
      end

      # Fetches HTML content by sending HTTP request to the provider URL and
      # parses the document (built as abstract <code>ProxyFetcher::Document</code>)
      # to return all the proxy entries (HTML nodes).
      #
      # @return [Array<ProxyFetcher::Document::Node>]
      #   Collection of extracted HTML nodes with full proxy info
      #
      def load_proxy_list(filters = { type: 'All_http' })
        doc = load_document(provider_url, filters)
        doc.xpath('//div/table/tbody/tr')
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
          proxy.addr = html_node.content_at('td[1]')
          proxy.port = Integer(html_node.content_at('td[2]').gsub(/^0+/, ''))
          proxy.anonymity = html_node.content_at('td[3]')
          proxy.country = html_node.content_at('td[5]')
          proxy.response_time = Integer(html_node.content_at('td[6]'))
          proxy.type = html_node.content_at('td[3]')
        end
      end
    end

    ProxyFetcher::Configuration.register_provider(:xroxy, XRoxy)
  end
end
