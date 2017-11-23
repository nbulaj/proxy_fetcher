module ProxyFetcher
  class Node
    attr_reader :node

    def initialize(node)
      @node = node
    end

    def search(selector, method)
      node.public_send(method, selector)
    end

    def at(selector, method)
      search(selector, method).first
    end

    def parse
      # implement me
    end
  end
end
