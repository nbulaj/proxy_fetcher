# frozen_string_literal: true

require "uri"
require "http"
require "logger"

require File.dirname(__FILE__) + "/proxy_fetcher/version"

require File.dirname(__FILE__) + "/proxy_fetcher/exceptions"
require File.dirname(__FILE__) + "/proxy_fetcher/configuration"
require File.dirname(__FILE__) + "/proxy_fetcher/configuration/providers_registry"
require File.dirname(__FILE__) + "/proxy_fetcher/proxy"
require File.dirname(__FILE__) + "/proxy_fetcher/manager"
require File.dirname(__FILE__) + "/proxy_fetcher/null_logger"

require File.dirname(__FILE__) + "/proxy_fetcher/utils/http_client"
require File.dirname(__FILE__) + "/proxy_fetcher/utils/proxy_validator"
require File.dirname(__FILE__) + "/proxy_fetcher/utils/proxy_list_validator"
require File.dirname(__FILE__) + "/proxy_fetcher/client/client"
require File.dirname(__FILE__) + "/proxy_fetcher/client/request"
require File.dirname(__FILE__) + "/proxy_fetcher/client/proxies_registry"

require File.dirname(__FILE__) + "/proxy_fetcher/document"
require File.dirname(__FILE__) + "/proxy_fetcher/document/adapters"
require File.dirname(__FILE__) + "/proxy_fetcher/document/node"
require File.dirname(__FILE__) + "/proxy_fetcher/document/adapters/abstract_adapter"
require File.dirname(__FILE__) + "/proxy_fetcher/document/adapters/nokogiri_adapter"
require File.dirname(__FILE__) + "/proxy_fetcher/document/adapters/oga_adapter"

##
# Ruby / JRuby lib for managing proxies
module ProxyFetcher
  # ProxyFetcher providers namespace
  module Providers
    require File.dirname(__FILE__) + "/proxy_fetcher/providers/base"
    require File.dirname(__FILE__) + "/proxy_fetcher/providers/checker_proxy"
    require File.dirname(__FILE__) + "/proxy_fetcher/providers/free_proxy_cz"
    require File.dirname(__FILE__) + "/proxy_fetcher/providers/free_proxy_list"
    require File.dirname(__FILE__) + "/proxy_fetcher/providers/free_proxy_list_socks"
    require File.dirname(__FILE__) + "/proxy_fetcher/providers/free_proxy_list_ssl"
    require File.dirname(__FILE__) + "/proxy_fetcher/providers/free_proxy_list_us"
    require File.dirname(__FILE__) + "/proxy_fetcher/providers/http_tunnel"
    require File.dirname(__FILE__) + "/proxy_fetcher/providers/mtpro"
    require File.dirname(__FILE__) + "/proxy_fetcher/providers/proxy_list"
    require File.dirname(__FILE__) + "/proxy_fetcher/providers/proxy_list_download"
    require File.dirname(__FILE__) + "/proxy_fetcher/providers/proxypedia"
    require File.dirname(__FILE__) + "/proxy_fetcher/providers/proxyscrape"
    require File.dirname(__FILE__) + "/proxy_fetcher/providers/scrapingant"
    require File.dirname(__FILE__) + "/proxy_fetcher/providers/xroxy"
  end

  @__config_access_lock__ = Mutex.new
  @__config_definition_lock__ = Mutex.new

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
    #          @client_timeout=3, @proxy_validation_timeout=3, @provider_proxies_load_timeout=30,
    #          @http_client=ProxyFetcher::HTTPClient, @proxy_validator=ProxyFetcher::ProxyValidator,
    #          @providers=[:free_proxy_list, ...], @adapter=ProxyFetcher::Document::NokogiriAdapter>
    #
    def config
      @__config_definition_lock__.synchronize do
        @config ||= ProxyFetcher::Configuration.new
      end
    end

    ##
    # Configures ProxyFetcher and yields config object for additional manipulations.

    # @yieldreturn [optional, types, ...] description
    #
    # @return [ProxyFetcher::Configuration]
    #   Configuration object.
    #
    def configure
      @__config_access_lock__.synchronize { yield config }
    end

    # Returns ProxyFetcher logger instance.
    #
    # @return [Logger, ProxyFetcher::NullLogger] logger object
    #
    def logger
      return @logger if defined?(@logger)

      @logger = config.logger || NullLogger.new
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
