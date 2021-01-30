# frozen_string_literal: true

require "json"

module ProxyFetcher
  module Providers
    # CheckerProxy provider class.
    class CheckerProxy < Base
      # Provider URL to fetch proxy list
      def provider_url
        "https://checkerproxy.net/api/archive/#{Time.now.to_date.to_s}"
      end

      def load_proxy_list(filters = {})
        html = load_html(provider_url, filters)
        JSON.parse(html)
      rescue JSON::ParserError
        []
      end

      # Converts JSON node (entry of N tags) to <code>ProxyFetcher::Proxy</code>
      # object.
      #
      # @param json_node [Object]
      #   JSON node from the <code>JSON</code> object.
      #
      # @return [ProxyFetcher::Proxy]
      #   Proxy object
      #
      def to_proxy(json_node)
        addr, port = json_node['addr'].split(":")

        ProxyFetcher::Proxy.new.tap do |proxy|
          proxy.addr = addr
          proxy.port = Integer(port)
          proxy.type = parse_type(json_node)
          proxy.country = parse_country(json_node)
          proxy.anonymity = parse_anonymity(json_node)
        end
      end

      private

      # Parses JSON node to extract proxy type.
      #
      # @param json_node [Object]
      #   JSON node from the <code>JSON</code> object.
      #
      # @return [String]
      #   Proxy type
      #
      def parse_type(json_node)
        type = json_node['type'].to_s

        return ProxyFetcher::Proxy::HTTP   if type&.casecmp("1")&.zero?
        return ProxyFetcher::Proxy::HTTPS  if type&.casecmp("2")&.zero?
        return ProxyFetcher::Proxy::SOCKS4 if type&.casecmp("3")&.zero?
        return ProxyFetcher::Proxy::SOCKS5 if type&.casecmp("4")&.zero?

        "Unknown"
      end

      # Parses JSON node to extract country name.
      #
      # @param json_node [Object]
      #   JSON node from the <code>JSON</code> object.
      #
      # @return [String]
      #   Country name
      #
      def parse_country(json_node)
        country = json_node['addr_geo_country']

        return country unless country.empty?

        "Unknown"
      end

      # Parses JSON node to extract anonymity kind.
      #
      # @param json_node [Object]
      #   JSON node from the <code>JSON</code> object.
      #
      # @return [String]
      #   Anonymity kind
      #
      def parse_anonymity(json_node)
        kind = json_node['kind'].to_s

        return "Transparent" if kind&.casecmp("0")&.zero?
        return "Anonymous"   if kind&.casecmp("2")&.zero?

        "Unknown"
      end
    end

    ProxyFetcher::Configuration.register_provider(:checker_proxy, CheckerProxy)
  end
end
