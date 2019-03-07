# frozen_string_literal: true

module ProxyFetcher
  # HTML document abstraction class. Used to work with different HTML parser adapters
  # such as Nokogiri, Oga or a custom one. Stores <i>backend</i< that will handle all
  # the DOM manipulation logic.
  class Document
    # @!attribute [r] backend
    #   @return [Object] Backend object that handles DOM processing
    attr_reader :backend

    # Parses raw HTML data to abstract ProxyFetcher document.
    #
    # @param data [String] HTML
    #
    # @return [ProxyFetcher::Document]
    #   ProxyFetcher document model
    #
    def self.parse(data)
      new(ProxyFetcher.config.adapter_class.parse(data))
    end

    # Initialize abstract ProxyFetcher HTML Document
    #
    # @return [Document]
    #
    def initialize(backend)
      @backend = backend
    end

    # Searches elements by XPath selector.
    #
    # @return [Array<ProxyFetcher::Document::Node>]
    #   collection of nodes
    #
    def xpath(*args)
      backend.xpath(*args).map { |node| backend.proxy_node.new(node) }
    end

    # Searches elements by CSS selector.
    #
    # @return [Array<ProxyFetcher::Document::Node>]
    #   collection of nodes
    #
    def css(*args)
      backend.css(*args).map { |node| backend.proxy_node.new(node) }
    end
  end
end
