# frozen_string_literal: true

require 'json'

module ProxyFetcher
  module Providers
    # ProxyDocker provider class.
    class ProxyDocker < Base
      # Provider URL to fetch proxy list
      def provider_url
        'https://www.proxydocker.com/en/api/proxylist/'
      end

      def provider_method
        :post
      end

      def provider_params
        {
          token: 'GmZyl0OJmmgrWakdzO7AFf6AWfkdledR6xmKvGmwmJg',
          country: 'all',
          city: 'all',
          state: 'all',
          port: 'all',
          type: 'all',
          anonymity: 'all',
          need: 'all',
          page: '1'
        }
      end

      def provider_headers
        {
          cookie: 'PHPSESSID=7f59558ee58b1e4352c4ab4c2f1a3c11'
        }
      end

      # Fetches HTML content by sending HTTP request to the provider URL and
      # parses the document (built as abstract <code>ProxyFetcher::Document</code>)
      # to return all the proxy entries (HTML nodes).
      #
      # @return [Array<ProxyFetcher::Document::Node>]
      #   Collection of extracted HTML nodes with full proxy info
      #
      # [NOTE] Doesn't support direct filters
      def load_proxy_list(*)
        json = JSON.parse(load_html(provider_url, {}))
        json.fetch('proxies', [])
      rescue JSON::ParserError
        []
      end

      # Converts JSON node  to <code>ProxyFetcher::Proxy</code>
      # object.
      #
      # @param node [Hash]
      #   JSON entry from the API response
      #
      # @return [ProxyFetcher::Proxy]
      #   Proxy object
      #
      def to_proxy(node)
        ProxyFetcher::Proxy.new.tap do |proxy|
          proxy.addr = node['ip']
          proxy.port = node['port']

          proxy.type = types_mapping.fetch(node['type'], ProxyFetcher::Proxy::HTTP)
          proxy.anonymity = "Lvl#{node['anonymity']}"
          proxy.country = node['country']
        end
      end

      def types_mapping
        {
          '16' => ProxyFetcher::Proxy::HTTP,
          '26' => ProxyFetcher::Proxy::HTTPS,
          '3' => ProxyFetcher::Proxy::SOCKS4,
          '4' => ProxyFetcher::Proxy::SOCKS5,
          '56' => ProxyFetcher::Proxy::HTTP, # CON25
          '6' => ProxyFetcher::Proxy::HTTP # CON80
        }
      end
    end

    ProxyFetcher::Configuration.register_provider(:proxy_docker, ProxyDocker)
  end
end
