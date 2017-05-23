module ProxyFetcher
  class Proxy
    attr_reader :addr, :port, :country, :response_time,
                :connection_time, :speed, :type, :anonimity

    def initialize(html_row)
      parse_row!(html_row)

      self
    end

    def connectable?
      connection = Net::HTTP.new(addr, port)
      connection.use_ssl = true if https?
      connection.open_timeout = ProxyFetcher::Manager.config.open_timeout
      connection.read_timeout = ProxyFetcher::Manager.config.read_timeout

      connection.start { |http| return true if http.request_head('/') }

      false
    rescue Timeout::Error, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::ECONNABORTED
      false
    end

    alias_method :valid?, :connectable?

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

    private

    # HideMyAss proxy list rows parsing by columns
    def parse_row!(html)
      html.xpath('td').each_with_index do |td, index|
        case index
        when 1
          @addr = parse_addr(td)
        when 2 then
          @port = Integer(td.content.strip)
        when 3 then
          @country = td.content.strip
        when 4
          @response_time = parse_response_time(td)
          @speed = parse_indicator_value(td)
        when 5
          @connection_time = parse_indicator_value(td)
        when 6 then
          @type = td.content.strip
        when 7
          @anonymity = td.content.strip
        else
          # nothing
        end
      end
    end

    def parse_addr(html)
      good = []
      bytes = []
      css = html.at_xpath('span/style/text()').to_s
      css.split.each { |l| good << Regexp.last_match(1) if l =~ /\.(.+?)\{.*inline/ }

      html.xpath('span/span | span | span/text()').each do |span|
        if span.is_a?(Nokogiri::XML::Text)
          bytes << Regexp.last_match(1) if span.content.strip =~ /\.{0,1}(.+)\.{0,1}/
        elsif (span['style'] && span['style'] =~ /inline/) ||
              (span['class'] && good.include?(span['class'])) ||
              (span['class'] =~ /^[0-9]/)

          bytes << span.content
        end
      end

      bytes.join('.').gsub(/\.+/, '.')
    end

    def parse_response_time(html)
      Integer(html.at_xpath('div')['rel'])
    end

    def parse_indicator_value(html)
      Integer(html.at('.indicator').attr('style').match(/width: (\d+)%/i)[1])
    end
  end
end
