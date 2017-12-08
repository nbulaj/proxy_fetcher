module ProxyFetcher
  class Document
    class AbstractAdapter
      attr_reader :document

      def initialize(document)
        @document = document
      end

      # You can override this method in your own adapter class
      def xpath(selector)
        document.xpath(selector)
      end

      # You can override this method in your own adapter class
      def css(selector)
        document.css(selector)
      end

      def proxy_node
        self.class.const_get('Node')
      end

      def self.setup!(*args)
        install_requirements!(*args)
      rescue LoadError => error
        raise Exceptions::AdapterSetupError.new(name, error.message)
      end
    end
  end
end
