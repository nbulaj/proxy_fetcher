module ProxyFetcher
  module Providers
    class HideMyAss < Base
      PROVIDER_URL = 'http://proxylist.hidemyass.com/'.freeze

      class << self
        def parse_entry(entry, proxy_instance)
          new(proxy_instance).parse!(entry)
        end

        def load_proxy_list
          doc = Nokogiri::HTML(load_html(PROVIDER_URL))
          doc.xpath('//table[@id="listable"]/tbody/tr')
        end
      end

      def parse!(html_doc)
        html_doc.xpath('td').each_with_index do |td, index|
          case index
          when 1
            set!(:addr, parse_addr(td))
          when 2 then
            set!(:port, Integer(td.content.strip))
          when 3 then
            set!(:country, td.content.strip)
          when 4
            set!(:response_time, parse_response_time(td))
            set!(:speed, parse_indicator_value(td))
          when 5
            set!(:connection_time, parse_indicator_value(td))
          when 6 then
            set!(:type, td.content.strip)
          when 7
            set!(:anonymity, td.content.strip)
          else
            # nothing
          end
        end
      end

      private

      def parse_addr(html_doc)
        good = []
        bytes = []
        css = html_doc.at_xpath('span/style/text()').to_s
        css.split.each { |l| good << Regexp.last_match(1) if l =~ /\.(.+?)\{.*inline/ }

        html_doc.xpath('span/span | span | span/text()').each do |span|
          if span.is_a?(Nokogiri::XML::Text)
            bytes << Regexp.last_match(1) if span.content.strip =~ /\.{0,1}(.+)\.{0,1}/
          elsif (span['style'] && span['style'] =~ /inline/) ||
                (span['class'] && good.include?(span['class'])) ||
                (span['class'] =~ /^[0-9]/)

            bytes << span.content
          end
        end

        bytes.join('.').gsub(/\.+/, '.')
      end

      def parse_response_time(html_doc)
        Integer(html_doc.at_xpath('div')['rel'])
      end

      def parse_indicator_value(html_doc)
        Integer(html_doc.at('.indicator').attr('style').match(/width: (\d+)%/i)[1])
      end
    end
  end
end

ProxyFetcher::Configuration.register_provider(:hide_my_ass, ProxyFetcher::Providers::HideMyAss)
