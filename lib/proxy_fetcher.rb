require 'uri'
require 'net/http'
require 'nokogiri'

require 'proxy_fetcher/configuration'
require 'proxy_fetcher/proxy'

module ProxyFetcher
  class Manager
    PROXY_PROVIDER_URL = 'http://proxylist.hidemyass.com/'.freeze

    class << self
      def config
        @config ||= ProxyFetcher::Configuration.new
      end
    end

    attr_reader :proxies

    # refresh: true - load proxy list from the remote server on initialization
    # refresh: false - just initialize the class, proxy list will be empty ([])
    def initialize(refresh: true)
      if refresh
        refresh_list!
      else
        @proxies = []
      end
    end

    # Update current proxy list from the provider
    def refresh_list!
      doc = Nokogiri::HTML(load_html(PROXY_PROVIDER_URL))
      rows = doc.xpath('//table[@id="listable"]/tbody/tr')

      @proxies = rows.map { |row| Proxy.new(row) }
    end

    alias_method :fetch!, :refresh_list!

    # Pop just first proxy (and back it to the end of the proxy list)
    def get
      first_proxy = @proxies.shift
      @proxies << first_proxy

      first_proxy
    end

    alias_method :pop, :get

    # Pop first valid proxy (and back it to the end of the proxy list)
    # Invalid proxies will be removed from the list
    def get!
      index = @proxies.find_index(&:connectable?)
      return if index < 0

      proxy = @proxies.delete_at(index)
      tail = @proxies[index..-1]

      @proxies = tail << proxy

      proxy
    end

    alias_method :pop!, :get!

    # Clean current proxy list from dead proxies (doesn't respond by timeout)
    def cleanup!
      proxies.keep_if(&:connectable?)
    end

    alias_method :validate!, :cleanup!

    # Just schema + host + port
    def raw_proxies
      proxies.map(&:url)
    end

    # No need to put all the attr_readers
    def inspect
      to_s
    end

    private

    # Get HTML from the requested URL
    def load_html(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.get(uri.request_uri)
      response.body
    end
  end
end
