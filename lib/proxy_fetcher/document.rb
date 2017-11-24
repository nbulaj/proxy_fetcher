module ProxyFetcher
  class Document
    class << self
      def parse(data, adapter:)
        new(adapter.parse(data))
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
