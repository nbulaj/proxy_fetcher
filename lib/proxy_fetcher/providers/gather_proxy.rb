require 'json'

module ProxyFetcher
  module Providers
    # GatherProxy provider class.
    class GatherProxy < Base
      # Provider URL to fetch proxy list
      PROVIDER_URL = 'http://www.gatherproxy.com/'.freeze

      # Fetches HTML content by sending HTTP request to the provider URL and
      # parses the document (built as abstract <code>ProxyFetcher::Document</code>)
      # to return all the proxy entries (HTML nodes).
      #
      # @return [Array<ProxyFetcher::Document::Node>]
      #   Collection of extracted HTML nodes with full proxy info
      #
      def load_proxy_list(*)
        doc = load_document(PROVIDER_URL)
        doc.xpath('//div[@class="proxy-list"]/table/script')
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
          proxy.addr = json['PROXY_IP']
          proxy.port = json['PROXY_PORT'].to_i(16)
          proxy.anonymity = json['PROXY_TYPE']
          proxy.country = json['PROXY_COUNTRY']
          proxy.response_time = json['PROXY_TIME'].to_i
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
