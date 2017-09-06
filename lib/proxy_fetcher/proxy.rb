module ProxyFetcher
  class Proxy
    attr_accessor :addr, :port, :type, :country, :response_time, :anonymity

    TYPES = [
      HTTP = 'HTTP'.freeze,
      HTTPS = 'HTTPS'.freeze,
      SOCKS4 = 'SOCKS4'.freeze,
      SOCKS5 = 'SOCKS5'.freeze
    ].freeze

    TYPES.each do |proxy_type|
      define_method "#{proxy_type.downcase}?" do
        !type.nil? && type.upcase.include?(proxy_type)
      end
    end

    def ssl?
      https? || socks4? || socks5?
    end

    def initialize(attributes = {})
      attributes.each do |attr, value|
        public_send("#{attr}=", value)
      end
    end

    def connectable?
      ProxyFetcher.config.proxy_validator.connectable?(addr, port)
    end

    alias valid? connectable?

    def uri
      URI::Generic.build(host: addr, port: port)
    end

    def url
      "#{addr}:#{port}"
    end
  end
end
