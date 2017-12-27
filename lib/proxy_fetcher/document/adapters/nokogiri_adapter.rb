module ProxyFetcher
  class Document
    # HTML parser adapter that uses Nokogiri as a backend.
    class NokogiriAdapter < AbstractAdapter
      def self.install_requirements!
        require 'nokogiri'
      end

      # Parses raw HTML content with specific gem.
      #
      # @param data [String]
      #   HTML content
      #
      # @return [ProxyFetcher::Document::NokogiriAdapter]
      #   Object with parsed document
      #
      def self.parse(data)
        new(::Nokogiri::HTML(data))
      end

      class Node < ProxyFetcher::Document::Node
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
