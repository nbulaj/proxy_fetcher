module ProxyFetcher
  module Providers
    class HideMyName < Base
      PROVIDER_URL = 'https://hidemy.name/en/proxy-list/?type=hs#list'.freeze

      class << self
        def parse_entry(entry, proxy_instance)
          new(proxy_instance).parse!(entry)
        end

        def load_proxy_list
          doc = Nokogiri::HTML(load_html(PROVIDER_URL))
          doc.xpath('//table[@class="proxy__t"]/tbody/tr')
        end
      end

      def parse!(html_entry)
        html_entry.xpath('td').each_with_index do |td, index|
          case index
          when 0
            set!(:addr, td.content.strip)
          when 1 then
            set!(:port, Integer(td.content.strip))
          when 2 then
            set!(:country, td.at_xpath('*//span[1]/following-sibling::text()[1]').content.strip)
          when 3
            set!(:response_time, Integer(td.at('p').content.strip[/\d+/]))
          when 4
            set!(:type, parse_type(td))
          when 5
            set!(:anonymity, td.content.strip)
          else
            # nothing
          end
        end
      end

      ProxyFetcher::Configuration.register_provider(:hide_my_name, self)

      private

      def parse_type(td)
        schemas = td.content.strip

        if schemas && schemas.downcase.include?('https')
          'HTTPS'
        else
          'HTTP'
        end
      end
    end
  end
end
