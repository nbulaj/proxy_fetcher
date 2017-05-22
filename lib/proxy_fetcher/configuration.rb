module ProxyFetcher
  class Configuration
    attr_accessor :open_timeout, :read_timeout

    def initialize
      @open_timeout = 3
      @read_timeout = 3
    end
  end
end
