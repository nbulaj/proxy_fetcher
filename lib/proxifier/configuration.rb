module Proxifier
  class Configuration
    attr_reader :open_timeout, :read_timeout

    def initialize
      @open_timeout = 3
      @read_timeout = 3
    end
  end
end
