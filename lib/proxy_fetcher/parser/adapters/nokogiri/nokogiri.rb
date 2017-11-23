require 'nokogiri'
require 'node'

module ProxyFetcher
  module Adapters
    class Nokogiri < Abstract
      def self.parse(data, options = {})
        new(::Nokogiri::HTML(data))
      end

      def xpath(selector)
        doc.xpath(selector)
      end

      def css(selector)
        doc.css(selector)
      end

      def proxy_node
        ::ProxyFetcher::NokogiriNode
      end
    end
  end
end
