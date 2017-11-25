require 'json'

module ProxyFetcher
  module Providers
    class GatherProxy < Base
      PROVIDER_URL = 'http://www.gatherproxy.com/'.freeze

      def load_proxy_list(*)
        doc = load_document(PROVIDER_URL)
        doc.xpath('//div[@class="proxy-list"]/table/script')
      end

      def to_proxy(html_node)
        json = parse_json(html_node)

        ProxyFetcher::Proxy.new.tap do |proxy|
          proxy.addr = json['PROXY_IP']
          proxy.port = json['PROXY_PORT'].to_i(16)
          proxy.anonymity = json['PROXY_TYPE']
          proxy.country = json['PROXY_COUNTRY']
          proxy.response_time = json['PROXY_TIME'].to_i
          proxy.type = ProxyFetcher::Proxy::HTTP
        end
      end

      private

      def parse_json(html_node)
        javascript = html_node.content[/{.+}/im]
        JSON.parse(javascript)
      end
    end

    ProxyFetcher::Configuration.register_provider(:gather_proxy, GatherProxy)
  end
end
