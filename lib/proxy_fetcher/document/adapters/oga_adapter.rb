module ProxyFetcher
  class Document
    # HTML parser adapter that uses Oga as a backend.
    class OgaAdapter < AbstractAdapter
      def self.install_requirements!
        require 'oga'
      end

      # Parses raw HTML content with specific gem.
      #
      # @param data [String]
      #   HTML content
      #
      # @return [ProxyFetcher::Document::OgaAdapter]
      #   Object with parsed document
      #
      def self.parse(data)
        new(::Oga.parse_html(data))
      end

      class Node < ProxyFetcher::Document::Node
        def attr(*args)
          clear(node.attribute(*args).value)
        end

        def content
          clear(node.text)
        end

        def html
          node.to_xml
        end
      end
    end
  end
end
