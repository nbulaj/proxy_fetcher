module ProxyFetcher
  class NokogiriNode < Node
    def parse
      node.content
    end
  end
end
