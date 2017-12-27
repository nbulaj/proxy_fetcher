module ProxyFetcher
  # Proxy object
  class Proxy
    attr_accessor :addr, :port, :type, :country, :response_time, :anonymity

    # Proxy type
    TYPES = [
      HTTP = 'HTTP'.freeze,
      HTTPS = 'HTTPS'.freeze,
      SOCKS4 = 'SOCKS4'.freeze,
      SOCKS5 = 'SOCKS5'.freeze
    ].freeze

    # Proxy type predicates (#socks4?, #https?)
    #
    # @return [Boolean]
    #   true if proxy of requested type, otherwise false.
    #
    TYPES.each do |proxy_type|
      define_method "#{proxy_type.downcase}?" do
        !type.nil? && type.upcase.include?(proxy_type)
      end
    end

    # Returns true if proxy is secure (works through https, socks4 or socks5).
    #
    # @return [Boolean]
    #   true if proxy is secure, otherwise false.
    #
    def ssl?
      https? || socks4? || socks5?
    end

    def initialize(attributes = {})
      attributes.each do |attr, value|
        public_send("#{attr}=", value)
      end
    end

    # Checks if proxy object is connectable? (can be used as a proxy for
    # network requests).
    #
    # @return [Boolean]
    #   true if proxy connectable, otherwise false.
    #
    def connectable?
      ProxyFetcher.config.proxy_validator.connectable?(addr, port)
    end

    alias valid? connectable?

    # Returns <code>URI::Generic</code> object with host and port values of the proxy.
    #
    # @return [URI::Generic]
    #   URI object.
    #
    def uri
      URI::Generic.build(host: addr, port: port)
    end

    # Returns <code>String</object> object with <i>addr:port<i> values of the proxy.
    #
    # @return [String]
    #   true if proxy connectable, otherwise false.
    #
    def url
      "#{addr}:#{port}"
    end
  end
end
