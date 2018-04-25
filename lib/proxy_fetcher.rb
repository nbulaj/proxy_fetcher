# frozen_string_literal: true

require 'uri'
require 'http'
require 'logger'

require File.dirname(__FILE__) + '/proxy_fetcher/version'

require File.dirname(__FILE__) + '/proxy_fetcher/exceptions'
require File.dirname(__FILE__) + '/proxy_fetcher/configuration'
require File.dirname(__FILE__) + '/proxy_fetcher/configuration/providers_registry'
require File.dirname(__FILE__) + '/proxy_fetcher/proxy'
require File.dirname(__FILE__) + '/proxy_fetcher/manager'

require File.dirname(__FILE__) + '/proxy_fetcher/utils/http_client'
require File.dirname(__FILE__) + '/proxy_fetcher/utils/proxy_validator'
require File.dirname(__FILE__) + '/proxy_fetcher/client/client'
require File.dirname(__FILE__) + '/proxy_fetcher/client/request'
require File.dirname(__FILE__) + '/proxy_fetcher/client/proxies_registry'

require File.dirname(__FILE__) + '/proxy_fetcher/document'
require File.dirname(__FILE__) + '/proxy_fetcher/document/adapters'
require File.dirname(__FILE__) + '/proxy_fetcher/document/node'
require File.dirname(__FILE__) + '/proxy_fetcher/document/adapters/abstract_adapter'
require File.dirname(__FILE__) + '/proxy_fetcher/document/adapters/nokogiri_adapter'
require File.dirname(__FILE__) + '/proxy_fetcher/document/adapters/oga_adapter'

##
# Ruby / JRuby lib for managing proxies
module ProxyFetcher
  # ProxyFetcher providers namespace
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

  # Main ProxyFetcher module.
  class << self
    ##
    # Returns ProxyFetcher configuration.
    #
    # @return [ProxyFetcher::Configuration]
    #   Configuration object.
    #
    # @example
    #   ProxyFetcher.config
    #
    #   #=> #<ProxyFetcher::Configuration:0x0000000241eec8 @user_agent="Mozilla/5.0, ...", @pool_size=10,
    #           @timeout=3, @http_client=ProxyFetcher::HTTPClient, @proxy_validator=ProxyFetcher::ProxyValidator,
    #           @providers=[:free_proxy_list, ...], @adapter=ProxyFetcher::Document::NokogiriAdapter>
    #
    def config
      @config ||= ProxyFetcher::Configuration.new
    end

    ##
    # Configures ProxyFetcher and yields config object for additional manipulations.

    # @yieldreturn [optional, types, ...] description
    #
    # @return [ProxyFetcher::Configuration]
    #   Configuration object.
    #
    def configure
      yield config
    end

    def logger
      config.logger
    end

    private

    # Configures default adapter if it isn't defined by the user.
    # @api private
    #
    def configure_adapter!
      config.adapter = Configuration::DEFAULT_ADAPTER if config.adapter.nil?
    end
  end

  configure_adapter!
end
