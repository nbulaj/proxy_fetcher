module ProxyFetcher
  module Adapters
    class Abstract
      attr_reader :doc

      def initialize(doc)
        @doc = doc
      end

      def xpath(*args)
        # implement me
      end

      def css(*args)
        # implement me
      end

      def proxy_node
        ::ProxyFetcher::Document::Node
      end
    end
  end
end
