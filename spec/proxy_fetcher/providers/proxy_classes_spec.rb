# frozen_string_literal: true

require "spec_helper"

describe "Proxy classes" do
  [
    [:free_proxy_list,            "FreeProxyList"],
    [:free_proxy_list_socks,      "FreeProxyListSocks"],
    [:free_proxy_list_ssl,        "FreeProxyListSSL"],
    [:free_proxy_list_us,         "FreeProxyListUS"],
    [:http_tunnel,                "HTTPTunnel"],
    [:mtpro,                      "MTPro"],
    [:proxy_list,                 "ProxyList"],
    [:proxy_list_download_http,   "ProxyListDownloadHTTP"],
    [:proxy_list_download_https,  "ProxyListDownloadHTTPS"],
    [:proxy_list_download_socks4, "ProxyListDownloadSOCKS4"],
    [:proxy_list_download_socks5, "ProxyListDownloadSOCKS5"],
    [:proxypedia,                 "Proxypedia"],
    [:proxyscrape_http,           "ProxyscrapeHTTP"],
    [:proxyscrape_socks4,         "ProxyscrapeSOCKS4"],
    [:proxyscrape_socks5,         "ProxyscrapeSOCKS5"],
    [:scrapingant,                "Scrapingant"],
    [:xroxy,                      "XRoxy"]
  ].each do |(provider_name, provider_klass)|
    describe Object.const_get("ProxyFetcher::Providers::#{provider_klass}") do
      before :all do
        ProxyFetcher.config.provider = provider_name
      end

      it_behaves_like "a manager"
    end
  end
end
