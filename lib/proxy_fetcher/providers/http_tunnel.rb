module ProxyFetcher
  module Providers
    class HTTPTunnel < Base
      PROVIDER_URL = 'http://www.httptunnel.ge/ProxyListForFree.aspx'.freeze

      def load_proxy_list(*)
        doc = load_document(PROVIDER_URL)
        doc.xpath('//table[contains(@id, "GridView")]/tr[(count(td)>2)]')
      end

      def to_proxy(html_element)
        ProxyFetcher::Proxy.new.tap do |proxy|
          uri = parse_proxy_uri(html_element)
          proxy.addr = uri.host
          proxy.port = uri.port

          proxy.country = parse_country(html_element)
          proxy.anonymity = parse_anonymity(html_element)
          proxy.type = ProxyFetcher::Proxy::HTTP
        end
      end

      private

      def parse_proxy_uri(element)
        full_addr = parse_element(element, 'td[1]')
        URI.parse("http://#{full_addr}")
      end

      def parse_country(element)
        element.at('img').attr('title')
      end

      def parse_anonymity(element)
        transparency = parse_element(element, 'td[5]').to_sym

        {
          A: 'Anonimous',
          E: 'Elite',
          T: 'Transparent',
          U: 'Unknown'
        }.fetch(transparency, 'Unknown')
      end
    end

    ProxyFetcher::Configuration.register_provider(:http_tunnel, HTTPTunnel)
  end
end
