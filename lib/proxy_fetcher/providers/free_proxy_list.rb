module ProxyFetcher
  module Providers
    class FreeProxyList < Base
      PROVIDER_URL = 'https://free-proxy-list.net/'.freeze

      class << self
        def load_proxy_list
          doc = Nokogiri::HTML(load_html(PROVIDER_URL))
          doc.xpath('//table[@id="proxylisttable"]/tbody/tr')
        end
      end

      def parse!(html_entry)
        html_entry.xpath('td').each_with_index do |td, index|
          case index
          when 0
            set!(:addr, td.content.strip)
          when 1 then
            set!(:port, Integer(td.content.strip))
          when 3 then
            set!(:country, td.content.strip)
          when 4
            set!(:anonymity, td.content.strip)
          when 6
            set!(:type, parse_type(td))
          else
            # nothing
          end
        end
      end

      private

      def parse_type(td)
        type = td.content.strip

        if type && type.downcase.include?('yes')
          'HTTPS'
        else
          'HTTP'
        end
      end
    end

    ProxyFetcher::Configuration.register_provider(:free_proxy_list, FreeProxyList)
  end
end
