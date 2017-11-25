require 'base64'

module ProxyFetcher
  module Providers
    class ProxyList < Base
      PROVIDER_URL = 'https://proxy-list.org/english/index.php'.freeze

      def load_proxy_list(filters = {})
        doc = load_document(PROVIDER_URL, filters)
        doc.css('.table-wrap .table ul')
      end

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

      def parse_proxy_uri(html_node)
        full_addr = ::Base64.decode64(html_node.at_css('li script').html.match(/'(.+)'/)[1])
        URI.parse("http://#{full_addr}")
      end
    end

    ProxyFetcher::Configuration.register_provider(:proxy_list, ProxyList)
  end
end
