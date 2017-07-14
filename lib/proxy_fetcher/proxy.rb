module ProxyFetcher
  class Proxy
    attr_reader :addr, :port, :country, :response_time,
                :connection_time, :speed, :type, :anonymity

    def initialize(html_row)
      ProxyFetcher.config.provider.parse_entry(html_row, self)

      self
    end

    def connectable?
      connection = Net::HTTP.new(addr, port)
      connection.use_ssl = true if https?
      connection.open_timeout = ProxyFetcher.config.open_timeout
      connection.read_timeout = ProxyFetcher.config.read_timeout

      connection.start { |http| return true if http.request_head('/') }

      false
    rescue Timeout::Error, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::ECONNABORTED, Errno::EOFError
      false
    end

    alias valid? connectable?

    def http?
      type.casecmp('http').zero?
    end

    def https?
      type.casecmp('https').zero?
    end

    def fast?
      speed >= 66
    end

    def medium?
      speed >= 33 && speed < 66
    end

    def slow?
      speed < 33
    end

    def uri
      URI::Generic.build(host: addr, port: port, scheme: type)
    end

    def url
      uri.to_s
    end
  end
end
