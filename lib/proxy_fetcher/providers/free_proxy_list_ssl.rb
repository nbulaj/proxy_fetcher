module ProxyFetcher
  module Providers
    class FreeProxyListSSL < Base
      PROVIDER_URL = 'https://www.sslproxies.org/'.freeze

      # [NOTE] Doesn't support filtering
      def load_proxy_list(*)
        doc = load_document(PROVIDER_URL, {})
        doc.xpath('//table[@id="proxylisttable"]/tbody/tr')
      end

      def to_proxy(html_element)
        ProxyFetcher::Proxy.new.tap do |proxy|
          proxy.addr = parse_element(html_element, 'td[1]')
          proxy.port = convert_to_int(parse_element(html_element, 'td[2]'))
          proxy.country = parse_element(html_element, 'td[4]')
          proxy.anonymity = parse_element(html_element, 'td[5]')
          proxy.type = HTTPS
        end
      end
    end

    ProxyFetcher::Configuration.register_provider(:free_proxy_list_ssl, FreeProxyListSSL)
  end
end
