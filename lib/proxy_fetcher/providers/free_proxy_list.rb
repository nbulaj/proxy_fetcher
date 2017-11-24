module ProxyFetcher
  module Providers
    class FreeProxyList < Base
      PROVIDER_URL = 'https://free-proxy-list.net/'.freeze

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
          proxy.type = parse_type(html_node)
        end
      end

      private

      def parse_type(html_node)
        https = html_node.content_at('td[6]')
        https && https.casecmp('yes').zero? ? ProxyFetcher::Proxy::HTTPS : ProxyFetcher::Proxy::HTTP
      end
    end

    ProxyFetcher::Configuration.register_provider(:free_proxy_list, FreeProxyList)
  end
end
