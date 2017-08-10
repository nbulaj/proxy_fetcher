require 'uri'
require 'net/http'
require 'nokogiri'

require 'proxy_fetcher/configuration'
require 'proxy_fetcher/proxy'
require 'proxy_fetcher/manager'
require 'proxy_fetcher/providers/base'
require 'proxy_fetcher/providers/free_proxy_list'
require 'proxy_fetcher/providers/free_proxy_list_ssl'
require 'proxy_fetcher/providers/hide_my_name'
require 'proxy_fetcher/providers/proxy_docker'
require 'proxy_fetcher/providers/xroxy'

module ProxyFetcher
  class << self
    def config
      @config ||= ProxyFetcher::Configuration.new
    end
  end
end
