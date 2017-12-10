module ProxyFetcher
  class Document
    class NokogiriAdapter < AbstractAdapter
      def self.install_requirements!
        require 'nokogiri'
      end

      def self.parse(data)
        new(::Nokogiri::HTML(data))
      end

      class Node < ProxyFetcher::Document::Node
        def at_xpath(*args)
          self.class.new(node.at_xpath(*args))
        end

        def at_css(*args)
          self.class.new(node.at_css(*args))
        end

        def attr(*args)
          clear(node.attr(*args))
        end

        def content
          clear(node.content)
        end

        def html
          node.inner_html
        end
      end
    end
  end
end
