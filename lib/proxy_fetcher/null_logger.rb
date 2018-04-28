# frozen_string_literal: true

module ProxyFetcher
  class NullLogger
    # @return [nil]
    def unknown(*)
      nil
    end

    # @return [nil]
    def fatal(*)
      nil
    end

    # @return [nil]
    def error(*)
      nil
    end

    # @return [nil]
    def warn(*)
      nil
    end

    # @return [nil]
    def info(*)
      nil
    end

    # @return [nil]
    def debug(*)
      nil
    end
  end
end
