module ProxyFetcher
  module Providers
    class ProxyDocker < Base
      PROVIDER_URL = 'https://www.proxydocker.com/en'.freeze

      # [NOTE] Doesn't support direct filters
      def load_proxy_list(*)
        doc = load_document(PROVIDER_URL, {})
        doc.xpath('//table[contains(@class, "table")]/tr[(not(@id="proxy-table-header")) and (count(td)>2)]')
      end

      def to_proxy(html_element)
        ProxyFetcher::Proxy.new.tap do |proxy|
          uri = URI("//#{parse_element(html_element, 'td[1]')}")
          proxy.addr = uri.host
          proxy.port = uri.port

          proxy.type = parse_element(html_element, 'td[2]')
          proxy.anonymity = parse_element(html_element, 'td[3]')
          proxy.country = parse_element(html_element, 'td[5]')
        end
      end
    end

    ProxyFetcher::Configuration.register_provider(:proxy_docker, ProxyDocker)
  end
end
