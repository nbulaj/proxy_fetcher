module ProxyFetcher
  module Providers
    class XRoxy < Base
      PROVIDER_URL = 'http://www.xroxy.com/proxylist.php?port=&type=All_http'.freeze

      class << self
        def load_proxy_list
          doc = Nokogiri::HTML(load_html(PROVIDER_URL))
          doc.xpath('//div[@id="content"]/table[1]/tr[contains(@class, "row")]')
        end
      end

      def parse!(html_entry)
        html_entry.xpath('td').each_with_index do |td, index|
          case index
          when 1
            set!(:addr, td.content.strip)
          when 2
            set!(:port, Integer(td.content.strip))
          when 3
            set!(:anonymity,  td.content.strip)
          when 4
            ssl = td.content.strip.downcase
            set!(:type, ssl.include?('true') ? 'HTTPS' : 'HTTP' )
          when 5 then
            set!(:country, td.content.strip)
          when 6
            set!(:response_time, Integer(td.content.strip))
          else
            # nothing
          end
        end
      end
    end
  end
end

ProxyFetcher::Configuration.register_provider(:xroxy, ProxyFetcher::Providers::XRoxy)
