# frozen_string_literal: true

module ProxyFetcher
  # Proxy object
  class Proxy
    # @!attribute [rw] addr
    #   @return [String] address (IP or domain)
    attr_accessor :addr

    # @!attribute [rw] port
    #   @return [Integer] port
    attr_accessor :port

    # @!attribute [rw] type
    #   @return [String] type (SOCKS, HTTP(S))
    attr_accessor :type

    # @!attribute [rw] country
    #   @return [String] country or country code
    attr_accessor :country

    # @!attribute [rw] response_time
    #   @return [Integer] response time (value and measurements depends on the provider)
    attr_accessor :response_time

    # @!attribute [rw] anonymity
    #   @return [String] anonymity level (high, elite, transparent, etc)
    attr_accessor :anonymity

    # Proxy types
    TYPES = [
      HTTP = "HTTP",
      HTTPS = "HTTPS",
      SOCKS4 = "SOCKS4",
      SOCKS5 = "SOCKS5"
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

    # Initialize new Proxy
    #
    # @param attributes [Hash]
    #   proxy attributes
    #
    # @return [Proxy]
    #
    def initialize(attributes = {})
      attributes.each do |attr, value|
        public_send("#{attr}=", value)
      end
    end

    # Checks if proxy object is connectable (can be used as a proxy for
    # HTTP requests).
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

    # Returns <code>String</code> object with <i>addr:port</i> values of the proxy.
    #
    # @param scheme [Boolean]
    #   Indicates if URL must include proxy type
    #
    # @return [String]
    #   true if proxy connectable, otherwise false.
    #
    def url(scheme: false)
      if scheme
        URI::Generic.build(scheme: type, host: addr, port: port).to_s
      else
        URI::Generic.build(host: addr, port: port).to_s
      end
    end

    def ==(other)
      other.is_a?(Proxy) && addr == other.addr && port == other.port
    end

    def eql?(other)
      hash.eql?(other.hash)
    end

    def hash
      [addr.hash, port.hash].hash
    end
  end
end
