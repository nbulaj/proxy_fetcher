module ProxyFetcher
  module Providers
    class ProxyDocker < Base
      PROVIDER_URL = 'https://www.proxydocker.com/en'.freeze

      class << self
        def load_proxy_list
          doc = Nokogiri::HTML(load_html(PROVIDER_URL))
          doc.xpath('//table[contains(@class, "table")]/tr[(not(@id="proxy-table-header")) and (count(td)>2)]')
        end
      end

      def parse!(html_entry)
        html_entry.xpath('td').each_with_index do |td, index|
          case index
          when 0
            uri = URI("//#{td.content.strip}")

            set!(:addr, uri.host)
            set!(:port, uri.port)
          when 1
            set!(:type,  td.content.strip)
          when 2
            set!(:anonymity, td.content.strip)
          when 4 then
            set!(:country, td.content.strip)
          else
            # nothing
          end
        end
      end
    end

    ProxyFetcher::Configuration.register_provider(:proxy_docker, ProxyDocker)
  end
end
