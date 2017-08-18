require 'base64'

module ProxyFetcher
  module Providers
    class ProxyList < Base
      PROVIDER_URL = 'https://proxy-list.org/english/index.php'.freeze

      def load_proxy_list
        doc = Nokogiri::HTML(load_html(PROVIDER_URL))
        doc.css('.table-wrap .table ul')
      end

      def to_proxy(html_element)
        ProxyFetcher::Proxy.new.tap do |proxy|
          uri = parse_proxy_uri(html_element)
          proxy.addr = uri.host
          proxy.port = uri.port

          proxy.type = parse_element(html_element, 'li[2]')
          proxy.anonymity = parse_element(html_element, 'li[4]')
          proxy.country = clear(html_element.at_xpath("li[5]//span[@class='country']").attr('title'))
        end
      end

      private

      def parse_proxy_uri(element)
        full_addr = ::Base64.decode64(element.at('li script').inner_html.match(/'(.+)'/)[1])
        URI.parse("http://#{full_addr}")
      end
    end

    ProxyFetcher::Configuration.register_provider(:proxy_list, ProxyList)
  end
end
