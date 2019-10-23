# frozen_string_literal: true

module ProxyFetcher
  class Document
    # HTML parser adapter that uses Oga as a backend.
    class OgaAdapter < AbstractAdapter
      # Requires Oga gem to the application.
      def self.install_requirements!
        require "oga"
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

      # Oga DOM node
      class Node < ProxyFetcher::Document::Node
        # Returns HTML node attribute value.
        #
        # @return [String] attribute value
        #
        def attr(*args)
          clear(node.attribute(*args).value)
        end

        # Returns HTML node inner text value clean from
        # whitespaces, tabs, etc.
        #
        # @return [String] node inner text
        #
        def content
          clear(node.text)
        end

        # Returns node inner HTML.
        #
        # @return [String] inner HTML
        #
        def html
          node.to_xml
        end
      end
    end
  end
end
