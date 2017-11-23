require 'uri'
require 'net/https'
require 'nokogiri'

require File.dirname(__FILE__) + '/proxy_fetcher/exceptions'
require File.dirname(__FILE__) + '/proxy_fetcher/configuration'
require File.dirname(__FILE__) + '/proxy_fetcher/configuration/providers_registry'
require File.dirname(__FILE__) + '/proxy_fetcher/proxy'
require File.dirname(__FILE__) + '/proxy_fetcher/manager'

require File.dirname(__FILE__) + '/proxy_fetcher/utils/http_client'
require File.dirname(__FILE__) + '/proxy_fetcher/utils/html'
require File.dirname(__FILE__) + '/proxy_fetcher/utils/proxy_validator'
require File.dirname(__FILE__) + '/proxy_fetcher/client/client'
require File.dirname(__FILE__) + '/proxy_fetcher/client/request'
require File.dirname(__FILE__) + '/proxy_fetcher/client/proxies_registry'

require File.dirname(__FILE__) + '/proxy_fetcher/parser/document'
require File.dirname(__FILE__) + '/proxy_fetcher/parser/node'
require File.dirname(__FILE__) + '/proxy_fetcher/parser/adapters/abstract'

module ProxyFetcher
  module Providers
    require File.dirname(__FILE__) + '/proxy_fetcher/providers/base'
    require File.dirname(__FILE__) + '/proxy_fetcher/providers/free_proxy_list'
    require File.dirname(__FILE__) + '/proxy_fetcher/providers/free_proxy_list_ssl'
    require File.dirname(__FILE__) + '/proxy_fetcher/providers/gather_proxy'
    require File.dirname(__FILE__) + '/proxy_fetcher/providers/http_tunnel'
    require File.dirname(__FILE__) + '/proxy_fetcher/providers/proxy_docker'
    require File.dirname(__FILE__) + '/proxy_fetcher/providers/proxy_list'
    require File.dirname(__FILE__) + '/proxy_fetcher/providers/xroxy'
  end

  class << self
    def config
      @config ||= ProxyFetcher::Configuration.new
    end

    def configure
      yield config
    end
  end
end
