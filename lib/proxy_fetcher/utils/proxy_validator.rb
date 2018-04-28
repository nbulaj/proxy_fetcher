# frozen_string_literal: true

module ProxyFetcher
  # Default ProxyFetcher proxy validator that checks either proxy
  # connectable or not. It tries to send HEAD request to default
  # URL to check if proxy can be used (aka connectable?).
  class ProxyValidator
    # Default URL that will be used to check if proxy can be used.
    URL_TO_CHECK = 'https://google.com'.freeze

    # Initialize new ProxyValidator instance
    #
    # @param proxy_addr [String] proxy address or IP
    # @param proxy_port [String, Integer] proxy port
    #
    # @return [ProxyValidator]
    #
    def initialize(proxy_addr, proxy_port)
      timeout = ProxyFetcher.config.timeout

      @http = HTTP.via(proxy_addr, proxy_port.to_i).timeout(connect: timeout, read: timeout)
    end

    # Checks if proxy is connectable (can be used to connect
    # resources via proxy server).
    #
    # @return [Boolean]
    #   true if connection to the server using proxy established, otherwise false
    #
    def connectable?
      @http.head(URL_TO_CHECK)
    rescue StandardError
      false
    end

    # Short variant to validate proxy.
    #
    # @param proxy_addr [String] proxy address or IP
    # @param proxy_port [String, Integer] proxy port
    #
    # @return [Boolean]
    #   true if connection to the server using proxy established, otherwise false
    #
    def self.connectable?(proxy_addr, proxy_port)
      new(proxy_addr, proxy_port).connectable?
    end
  end
end
