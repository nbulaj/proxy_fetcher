module ProxyFetcher
  class Proxy < OpenStruct
    def connectable?
      ProxyFetcher.config.http_client.connectable?(url)
    end

    alias valid? connectable?

    %i[slow medium fast].each do |method|
      define_method "#{method}?" do
        speed == method
      end
    end

    def http?
      type.casecmp('http').zero?
    end

    def https?
      type.casecmp('https').zero?
    end

    def uri
      URI::Generic.build(host: addr, port: port, scheme: type)
    end

    def url
      uri.to_s
    end
  end
end
