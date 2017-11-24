module ProxyFetcher
  module Providers
    class XRoxy < Base
      PROVIDER_URL = 'http://www.xroxy.com/proxylist.php'.freeze

      def load_proxy_list(filters = { type: 'All_http' })
        doc = load_document(PROVIDER_URL, filters)
        doc.xpath('//div[@id="content"]/table[1]/tr[contains(@class, "row")]')
      end

      def to_proxy(html_node)
        ProxyFetcher::Proxy.new.tap do |proxy|
          proxy.addr = html_node.content_at('td[2]')
          proxy.port = convert_to_int(html_node.content_at('td[3]'))
          proxy.anonymity = html_node.content_at('td[4]')
          proxy.country = html_node.content_at('td[6]')
          proxy.response_time = convert_to_int(html_node.content_at('td[7]'))
          proxy.type = parse_type(html_node)
        end
      end

      private

      def parse_type(html_node)
        https = html_node.content_at('td[5]')
        https.casecmp('true').zero? ? ProxyFetcher::Proxy::HTTPS : ProxyFetcher::Proxy::HTTP
      end
    end

    ProxyFetcher::Configuration.register_provider(:xroxy, XRoxy)
  end
end
