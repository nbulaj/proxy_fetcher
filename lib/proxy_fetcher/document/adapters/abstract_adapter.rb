module ProxyFetcher
  class Document
    class AbstractAdapter
      attr_reader :doc

      def initialize(doc)
        @doc = doc
      end

      # You can override this method in your own adapter class
      def xpath(selector)
        doc.xpath(selector)
      end

      # You can override this method in your own adapter class
      def css(selector)
        doc.css(selector)
      end

      def proxy_node
        self.class.const_get('Node')
      end

      def self.setup!(*args)
        install_requirements!(*args)
      rescue LoadError => error
        raise Exceptions::AdapterSetupError, error.message
      end
    end
  end
end
