require 'irb'

module ProxyFetcher
  module Providers
    class HTTPTunnel < Base
      PROVIDER_URL = 'http://www.httptunnel.ge/ProxyListForFree.aspx'.freeze

      def load_proxy_list(*)
        doc = load_document(PROVIDER_URL)
        doc.xpath('//table[contains(@id, "GridView")]/tr[(count(td)>2)]')
      end

      def to_proxy(html_node)
        ProxyFetcher::Proxy.new.tap do |proxy|
          uri = parse_proxy_uri(html_node)
          proxy.addr = uri.host
          proxy.port = uri.port

          proxy.country = parse_country(html_node)
          proxy.anonymity = parse_anonymity(html_node)
          proxy.type = ProxyFetcher::Proxy::HTTP
        end
      end

      private

      def parse_proxy_uri(html_node)
        full_addr = html_node.content_at('td[1]')
        URI.parse("http://#{full_addr}")
      end

      def parse_country(html_node)
        html_node.find('.//img').attr('title')
      end

      def parse_anonymity(html_node)
        transparency = html_node.content_at('td[5]').to_sym

        {
          A: 'Anonymous',
          E: 'Elite',
          T: 'Transparent',
          U: 'Unknown'
        }.fetch(transparency, 'Unknown')
      end
    end

    ProxyFetcher::Configuration.register_provider(:http_tunnel, HTTPTunnel)
  end
end
