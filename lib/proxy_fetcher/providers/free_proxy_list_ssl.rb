module ProxyFetcher
  module Providers
    class FreeProxyListSSL < Base
      PROVIDER_URL = 'https://www.sslproxies.org/'.freeze

      # [NOTE] Doesn't support filtering
      def load_proxy_list(*)
        doc = load_document(PROVIDER_URL, {})
        doc.xpath('//table[@id="proxylisttable"]/tbody/tr')
      end

      def to_proxy(html_node)
        ProxyFetcher::Proxy.new.tap do |proxy|
          proxy.addr = html_node.content_at('td[1]')
          proxy.port = convert_to_int(html_node.content_at('td[2]'))
          proxy.country = html_node.content_at('td[4]')
          proxy.anonymity = html_node.content_at('td[5]')
          proxy.type = ProxyFetcher::Proxy::HTTPS
        end
      end
    end

    ProxyFetcher::Configuration.register_provider(:free_proxy_list_ssl, FreeProxyListSSL)
  end
end
