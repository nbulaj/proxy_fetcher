require 'uri'
require 'net/http'
require 'nokogiri'

require 'proxifier/proxy'

module Proxifier
  class Manager
    PROXY_PROVIDER_URL = 'http://proxylist.hidemyass.com/'.freeze

    attr_reader :proxies

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

    # Clean current proxies list from dead proxies
    def cleanup!
      proxies.keep_if(&:connectable?)
    end

    alias_method :validate!, :cleanup!

    # Just schema + host + port
    def raw_proxies
      proxies.map(&:url)
    end

    def inspect
      "#<#{self.class.name}>"
    end

    private

    def load_html(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.get(uri.request_uri)
      response.body
    end
  end
end
