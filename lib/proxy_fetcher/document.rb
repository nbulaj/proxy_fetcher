module ProxyFetcher
  # HTML document abstraction class. Used to work with different HTML parser adapters
  # such as Nokogiri, Oga or a custom one. Stores <i>backend</i< that will handle all
  # the DOM manipulation logic.
  class Document
    class << self
      def parse(data)
        new(ProxyFetcher.config.adapter.parse(data))
      end
    end

    attr_reader :backend

    def initialize(backend)
      @backend = backend
    end

    def xpath(*args)
      backend.xpath(*args).map { |node| backend.proxy_node.new(node) }
    end

    def css(*args)
      backend.css(*args).map { |node| backend.proxy_node.new(node) }
    end
  end
end
