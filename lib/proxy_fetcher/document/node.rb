# frozen_string_literal: true

module ProxyFetcher
  class Document
    # Abstract class for storing HTML elements that was parsed by
    # one of the <code>ProxyFetcher::Document</code> adapters class.
    class Node
      # @!attribute [r] node
      #   @return [Object] original DOM node, parsed by adapter backend
      attr_reader :node

      # Initialize new HTML node
      #
      # @return [Node]
      #
      def initialize(node)
        @node = node
      end

      # Searches for node in children using some selector (CSS or XPath).
      #
      # @param selector [String] selector (CSS or XPath)
      #
      # @return [Node] child node
      #
      def find(selector, method = :at_xpath)
        self.class.new(node.public_send(method, selector))
      end

      # Searches exact HTML element by XPath. Returns only one element.
      #
      # @return [ProxyFetcher::Document::Node]
      #   node
      #
      def at_xpath(*args)
        self.class.new(node.at_xpath(*args))
      end

      # Searches exact HTML element by CSS. Returns only one element.
      #
      # @return [ProxyFetcher::Document::Node]
      #   node
      #
      def at_css(*args)
        self.class.new(node.at_css(*args))
      end

      # Returns clean content (text) for the specific element.
      #
      # @return [String]
      #   HTML node content
      #
      def content_at(*args)
        clear(find(*args).content)
      end

      # Returns HTML node content.
      #
      # Abstract method, must be implemented for specific adapter class.
      #
      def content
        raise "`#{__method__}` must be implemented for specific adapter class!"
      end

      # Returns HTML node inner HTML.
      #
      # Abstract method, must be implemented for specific adapter class.
      #
      def html
        raise "`#{__method__}` must be implemented for specific adapter class!"
      end

      protected

      # Removes whitespaces, tabulation and other "garbage" for the text.
      #
      # @param text [String]
      #   text to clear
      #
      # @return [String]
      #   clean text
      #
      def clear(text)
        return "" if text.nil? || text.empty?

        text.strip.gsub(/[\t]/i, "")
      end
    end
  end
end
