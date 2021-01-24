# frozen_string_literal: true

require "spec_helper"
require "json"

require "evil-proxy"
require "evil-proxy/async"

describe ProxyFetcher::Client do
  before :all do
    ProxyFetcher.configure do |config|
      config.provider = :xroxy
      config.client_timeout = 5
      config.logger = ProxyFetcher::NullLogger.new
    end

    quiet = ENV.key?("LOG_MITM") ? ENV["LOG_MITM"] == "false" : true

    @server = EvilProxy::MITMProxyServer.new Port: 3128, Quiet: quiet
    @server.start
  end

  after :all do
    @server.shutdown
  end

  let(:local_proxy) { ProxyFetcher::Proxy.new(addr: "127.0.0.1", port: 3128, type: "HTTP, HTTPS") }

  # Use local proxy server in order to avoid side effects, non-working proxies, etc
  before :each do
    ProxyFetcher::Client::ProxiesRegistry.manager.instance_variable_set(:'@proxies', [local_proxy])
    allow_any_instance_of(ProxyFetcher::Providers::Base).to receive(:fetch_proxies).and_return([local_proxy])
  end

  context "GET request with the valid proxy" do
    it "successfully returns page content for HTTP" do
      content = ProxyFetcher::Client.get("http://httpbin.org/get")

      expect(content).not_to be_empty
    end

    # TODO: oh this SSL / MITM proxies ....
    xit "successfully returns page content for HTTPS" do
      content = ProxyFetcher::Client.get("https://httpbin.org/get")

      expect(content).not_to be_empty
    end

    it "successfully returns page content using custom proxy" do
      content = ProxyFetcher::Client.get("http://httpbin.org/get", options: { proxy: local_proxy })

      expect(content).not_to be_empty
    end
  end

  context "POST request with the valid proxy" do
    it "successfully returns page content for HTTP" do
      headers = {
        "X-Proxy-Fetcher-Version" => ProxyFetcher::VERSION::STRING
      }

      content = ProxyFetcher::Client.post(
        "http://httpbin.org/post",
        { param: "value" },
        headers: headers
      )

      expect(content).not_to be_empty

      json = JSON.parse(content)

      expect(json["headers"]["X-Proxy-Fetcher-Version"]).to eq(ProxyFetcher::VERSION::STRING)
      expect(json["headers"]["User-Agent"]).to eq(ProxyFetcher.config.user_agent)
    end
  end

  # TODO: EvilProxy incompatible with latest Ruby/Webrick
  # @see https://github.com/bbtfr/evil-proxy/issues/10
  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.6")
    context "PUT request with the valid proxy" do
      it "successfully returns page content for HTTP" do
        content = ProxyFetcher::Client.put("http://httpbin.org/put", "param=PutValue")

        expect(content).not_to be_empty

        json = JSON.parse(content)

        expect(json["form"]["param"]).to eq("PutValue")
      end
    end

    context "PATCH request with the valid proxy" do
      it "successfully returns page content for HTTP" do
        content = ProxyFetcher::Client.patch("http://httpbin.org/patch", param: "value")

        expect(content).not_to be_empty

        json = JSON.parse(content)

        expect(json["form"]["param"]).to eq("value")
      end
    end
  end

  context "DELETE request with the valid proxy" do
    it "successfully returns page content for HTTP" do
      content = ProxyFetcher::Client.delete("http://httpbin.org/delete")

      expect(content).not_to be_empty
    end
  end

  context "HEAD request with the valid proxy" do
    it "successfully works" do
      content = ProxyFetcher::Client.head("http://httpbin.org")

      expect(content).to be_empty
    end
  end

  context "retries" do
    it "raises an error when reaches max retries limit" do
      allow(ProxyFetcher::Client::Request).to receive(:execute).and_raise(StandardError)

      expect { ProxyFetcher::Client.get("http://httpbin.org", options: { max_retries: 10 }) }
        .to raise_error(ProxyFetcher::Exceptions::MaximumRetriesReached)
    end

    xit "raises an error when http request returns an error" do
      allow_any_instance_of(HTTP::Client).to receive(:get).and_return(StandardError.new)

      expect { ProxyFetcher::Client.get("http://httpbin.org") }
        .to raise_error(ProxyFetcher::Exceptions::MaximumRetriesReached)
    end

    it "refreshes proxy lists if no proxy found" do
      allow(ProxyFetcher::Manager.new).to receive(:proxies).and_return([])

      expect { ProxyFetcher::Client.get("http://httpbin.org") }
        .not_to raise_error
    end
  end

  xcontext "redirects" do
    it "follows redirect when present" do
      content = ProxyFetcher::Client.get("http://httpbin.org/absolute-redirect/2")

      expect(content).not_to be_empty
    end

    it "raises an error when reaches max redirects limit" do
      expect { ProxyFetcher::Client.get("http://httpbin.org/absolute-redirect/11") }
        .to raise_error(ProxyFetcher::Exceptions::MaximumRedirectsReached)
    end
  end
end
