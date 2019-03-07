# frozen_string_literal: true

require 'base64'

module ProxyFetcher
  module Providers
    # ProxyList provider class.
    class ProxyList < Base
      # Provider URL to fetch proxy list
      def provider_url
        'https://proxy-list.org/english/index.php'
      end

      # Fetches HTML content by sending HTTP request to the provider URL and
      # parses the document (built as abstract <code>ProxyFetcher::Document</code>)
      # to return all the proxy entries (HTML nodes).
      #
      # @return [Array<ProxyFetcher::Document::Node>]
      #   Collection of extracted HTML nodes with full proxy info
      #
      def load_proxy_list(filters = {})
        doc = load_document(provider_url, filters)
        doc.css('.table-wrap .table ul')
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

          proxy.type = html_node.content_at('li[2]')
          proxy.anonymity = html_node.content_at('li[4]')
          proxy.country = html_node.find("li[5]//span[@class='country']").attr('title')
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
        full_addr = ::Base64.decode64(html_node.at_css('li script').html.match(/'(.+)'/)[1])
        URI.parse("http://#{full_addr}")
      end
    end

    ProxyFetcher::Configuration.register_provider(:proxy_list, ProxyList)
  end
end
