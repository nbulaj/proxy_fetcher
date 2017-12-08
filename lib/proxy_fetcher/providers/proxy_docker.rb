module ProxyFetcher
  module Providers
    class ProxyDocker < Base
      PROVIDER_URL = 'https://www.proxydocker.com/'.freeze

      # [NOTE] Doesn't support direct filters
      def load_proxy_list(*)
        doc = load_document(PROVIDER_URL, {})
        doc.xpath('//table[contains(@class, "table")]/tr[(not(@id="proxy-table-header")) and (count(td)>2)]')
      end

      def to_proxy(html_node)
        ProxyFetcher::Proxy.new.tap do |proxy|
          uri = URI("//#{html_node.content_at('td[1]')}")
          proxy.addr = uri.host
          proxy.port = uri.port

          proxy.type = html_node.content_at('td[2]')
          proxy.anonymity = html_node.content_at('td[3]')
          proxy.country = html_node.content_at('td[5]')
        end
      end
    end

    ProxyFetcher::Configuration.register_provider(:proxy_docker, ProxyDocker)
  end
end
