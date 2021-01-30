# frozen_string_literal: true

module ProxyFetcher
  module Providers
    # XRoxy provider class.
    class XRoxy < Base
      # Provider URL to fetch proxy list
      def provider_url
        "https://www.xroxy.com/proxylist.php"
      end

      def pages_count
        99
      end

      def first_page_number
        0
      end

      def page_param_name
        'pnum'
      end

      def xpath
        "//tr[@class='row1' or @class='row0']"
      end

      # Converts HTML node (entry of N tags) to <code>ProxyFetcher::Proxy</code>
      # object.
      #
      # @param html_node [Object]
      #   HTML node from the <code>ProxyFetcher::Document</code> DOM model.
      #
      # @return [ProxyFetcher::Proxy]
      #   Proxy object
      #
      def to_proxy(html_node)
        ProxyFetcher::Proxy.new.tap do |proxy|
          proxy.addr = html_node.content_at("td[1]")
          proxy.port = Integer(html_node.content_at("td[2]").gsub(/^0+/, ""))
          proxy.anonymity = html_node.content_at("td[3]")
          proxy.country = html_node.content_at("td[5]")
          proxy.response_time = Integer(html_node.content_at("td[6]"))
          proxy.type = html_node.content_at("td[3]")
        end
      end
    end

    ProxyFetcher::Configuration.register_provider(:xroxy, XRoxy)
  end
end
