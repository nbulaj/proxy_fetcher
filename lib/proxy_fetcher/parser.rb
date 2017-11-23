module ProxyFetcher
  class Parser
    attr_reader :adapter

    def initialize(adapter)
      @adapter = adapter
    end
  end
end
