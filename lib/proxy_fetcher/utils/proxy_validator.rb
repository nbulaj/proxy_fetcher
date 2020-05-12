# frozen_string_literal: true

module ProxyFetcher
  # Default ProxyFetcher proxy validator that checks either proxy
  # connectable or not. It tries to send HEAD request to default
  # URL to check if proxy can be used (aka connectable?).
  class ProxyValidator
    # Default URL that will be used to check if proxy can be used.
    URL_TO_CHECK = "https://google.com"

    # Short variant to validate proxy.
    #
    # @param address [String] proxy address or IP
    # @param port [String, Integer] proxy port
    #
    # @return [Boolean]
    #   true if connection to the server using proxy established, otherwise false
    #
    def self.connectable?(address, port)
      new(address, port).connectable?
    end

    # Initialize new ProxyValidator instance
    #
    # @param address [String] Proxy address or IP
    # @param port [String, Integer] Proxy port
    # @param options [Hash] proxy options
    #   @option username [String] Proxy authentication username
    #   @option password [String] Proxy authentication password
    #   @option headers [Hash] Proxy headers
    #
    # @return [ProxyValidator]
    #
    def initialize(address, port, options: {})
      timeout = ProxyFetcher.config.proxy_validation_timeout
      proxy = [address, port.to_i]

      if options[:username] && options[:password]
        proxy << options[:username]
        proxy << options[:password]
      end

      proxy << options[:headers].to_h if options[:headers]

      @http = HTTP.follow.via(*proxy).timeout(connect: timeout, read: timeout)
    end

    # Checks if proxy is connectable (can be used to connect
    # resources via proxy server).
    #
    # @return [Boolean]
    #   true if connection to the server using proxy established, otherwise false
    #
    def connectable?
      ssl_context = OpenSSL::SSL::SSLContext.new
      ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE

      @http.head(URL_TO_CHECK, ssl_context: ssl_context).status.success?
    rescue StandardError
      false
    end
  end
end
