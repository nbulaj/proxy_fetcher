# frozen_string_literal: true

module ProxyFetcher
  class Document
    # Abstract HTML parser adapter class.
    # Handles document manipulations.
    class AbstractAdapter
      # @!attribute [r] events
      #   @return [Hash] A hash with events registered within a bus
      attr_reader :document

      # Initialize adapter
      #
      # @return [AbstractAdapter]
      #
      def initialize(document)
        @document = document
      end

      # You can override this method in your own adapter class
      #
      # @param selector [String]
      #   XPath selector
      #
      def xpath(selector)
        document.xpath(selector)
      end

      # You can override this method in your own adapter class
      #
      # @param selector [String]
      #   CSS selector
      #
      def css(selector)
        document.css(selector)
      end

      # Returns <code>Node</code> class that will handle HTML
      # nodes for particular adapter.
      #
      # @return [ProxyFetcher::Document::Node]
      #   node
      #
      def proxy_node
        self.class.const_get('Node')
      end

      # Installs adapter requirements.
      #
      # @raise [Exceptions::AdapterSetupError]
      #   adapter can't be install due to some error
      #
      def self.setup!(*args)
        install_requirements!(*args)
      rescue LoadError => error
        raise Exceptions::AdapterSetupError.new(name, error.message)
      end
    end
  end
end
