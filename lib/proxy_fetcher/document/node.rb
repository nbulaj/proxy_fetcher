module ProxyFetcher
  class Document
    class Node
      attr_reader :node

      def initialize(node)
        @node = node
      end

      def find(selector, method = :at_xpath)
        self.class.new(node.public_send(method, selector))
      end

      def content_at(*args)
        clear(find(*args).content)
      end

      def content
        raise "#{__method__} must be implemented in descendant class!"
      end

      def html
        raise "#{__method__} must be implemented in descendant class!"
      end

      protected

      def clear(text)
        return if text.nil? || text.empty?

        text.strip.gsub(/[ \t]/i, '')
      end
    end
  end
end
