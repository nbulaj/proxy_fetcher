module ProxyFetcher
  module Providers
    # FreeProxyListSSL provider class.
    class FreeProxyListSSL < Base
      # Provider URL to fetch proxy list
      PROVIDER_URL = 'https://www.sslproxies.org/'.freeze

      # Fetches HTML content by sending HTTP request to the provider URL and
      # parses the document (built as abstract <code>ProxyFetcher::Document</code>)
      # to return all the proxy entries (HTML nodes).
      #
      # @return [Array<ProxyFetcher::Document::Node>]
      #   Collection of extracted HTML nodes with full proxy info
      #
      # [NOTE] Doesn't support filtering
      def load_proxy_list(*)
        doc = load_document(PROVIDER_URL, {})
        doc.xpath('//table[@id="proxylisttable"]/tbody/tr')
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
          proxy.port = Integer(html_node.content_at('td[2]'))
          proxy.country = html_node.content_at('td[4]')
          proxy.anonymity = html_node.content_at('td[5]')
          proxy.type = ProxyFetcher::Proxy::HTTPS
        end
      end
    end

    ProxyFetcher::Configuration.register_provider(:free_proxy_list_ssl, FreeProxyListSSL)
  end
end
