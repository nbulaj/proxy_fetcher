module ProxyFetcher
  module Providers
    class Hidster < Base
      PROVIDER_URL = 'https://hidester.com/proxylist/'.freeze

      class << self
        def load_proxy_list
          doc = Nokogiri::HTML(load_html(PROVIDER_URL))
          doc.xpath('//div[@class="proxyListTable"]/table/tbody/tr[@class!="proxy-table-header"]')
        end
      end

      def parse!(html_entry)
        html_entry.xpath('td').each_with_index do |td, index|
          case index
          when 1
            set!(:addr, td.content.strip)
          when 2 then
            set!(:port, Integer(td.content.strip))
          when 3 then
            set!(:country, td.content.strip)
          when 4
            set!(:type, td.content.strip)
          when 6
            set!(:response_time, Integer(td.at('p').content.strip[/\d+/]))
          when 7
            set!(:anonymity, td.content.strip)
          else
            # nothing
          end
        end
      end
    end
  end
end

ProxyFetcher::Configuration.register_provider(:hidster, ProxyFetcher::Providers::Hidster)
