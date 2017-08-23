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
        type && type.upcase.include?(proxy_type)
      end
    end

    alias ssl? https?

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
