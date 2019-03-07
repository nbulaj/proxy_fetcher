# frozen_string_literal: true

require 'json'

module ProxyFetcher
  module Providers
    # ProxyDocker provider class.
    class ProxyDocker < Base
      attr_reader :cookie, :token

      # Provider URL to fetch proxy list
      def provider_url
        'https://www.proxydocker.com/en/api/proxylist/'
      end

      def provider_method
        :post
      end

      def provider_params
        {
          token: @token,
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
          cookie: @cookie
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
        load_dependencies

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

      private

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

      def load_dependencies
        client = ProxyFetcher.config.http_client.new('https://www.proxydocker.com')
        response = client.fetch_with_headers

        @cookie = load_cookie_from(response)
        @token = load_token_from(response)
      end

      def load_cookie_from(response)
        cookie_headers = (response.headers['Set-Cookie'] || [])
        cookie_headers.join('; ')
      end

      def load_token_from(response)
        html = response.body.to_s
        html[/meta\s+name\s*=["']_token["']\s+content.+["'](.+?)["']\s*>/i, 1]
      end
    end

    ProxyFetcher::Configuration.register_provider(:proxy_docker, ProxyDocker)
  end
end
