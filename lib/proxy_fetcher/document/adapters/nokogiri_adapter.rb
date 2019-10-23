# frozen_string_literal: true

module ProxyFetcher
  class Document
    # HTML parser adapter that uses Nokogiri as a backend.
    class NokogiriAdapter < AbstractAdapter
      # Requires Nokogiri gem to the application.
      def self.install_requirements!
        require "nokogiri"
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

      # Nokogiri DOM node
      class Node < ProxyFetcher::Document::Node
        # Returns HTML node attribute value.
        #
        # @return [String] attribute value
        #
        def attr(*args)
          clear(node.attr(*args))
        end

        # Returns HTML node inner text value clean from
        # whitespaces, tabs, etc.
        #
        # @return [String] node inner text
        #
        def content
          clear(node.content)
        end

        # Returns node inner HTML.
        #
        # @return [String] inner HTML
        #
        def html
          node.inner_html
        end
      end
    end
  end
end
