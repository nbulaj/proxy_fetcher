module ProxyFetcher
  module Providers
    class HideMyName < Base
      PROVIDER_URL = 'https://hidemy.name/en/proxy-list/?type=hs'.freeze

      def load_proxy_list
        doc = Nokogiri::HTML(load_html(PROVIDER_URL))
        doc.xpath('//table[@class="proxy__t"]/tbody/tr')
      end

      def to_proxy(html_element)
        ProxyFetcher::Proxy.new.tap do |proxy|
          proxy.addr = parse_element(html_element, 'td[1]')
          proxy.port = convert_to_int(parse_element(html_element, 'td[2]'))
          proxy.anonymity = parse_element(html_element, 'td[6]')

          proxy.country = parse_country(html_element)
          proxy.type = parse_type(html_element)

          response_time = parse_response_time(html_element)

          proxy.response_time = response_time
          proxy.speed = speed_from_response_time(response_time)
        end
      end

      private

      def parse_country(element)
        clear(element.at_xpath('*//span[1]/following-sibling::text()[1]').content)
      end

      def parse_type(element)
        schemas = parse_element(element, 'td[5]')

        if schemas && schemas.downcase.include?('https')
          HTTPS
        else
          HTTP
        end
      end

      def parse_response_time(element)
        convert_to_int(element.at_xpath('td[4]').content.strip[/\d+/])
      end

      def speed_from_response_time(response_time)
        if response_time < 1500
          :fast
        elsif response_time < 3000
          :medium
        else
          :slow
        end
      end
    end

    ProxyFetcher::Configuration.register_provider(:hide_my_name, HideMyName)
  end
end
