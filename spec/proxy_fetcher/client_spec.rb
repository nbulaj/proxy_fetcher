require 'spec_helper'
require 'json'

require 'evil-proxy'
require 'evil-proxy/async'

describe ProxyFetcher::Client do
  before :all do
    ProxyFetcher.configure do |config|
      config.provider = :hide_my_name
      config.timeout = 5
    end

    @server = EvilProxy::MITMProxyServer.new Port: 3128
    @server.start
  end

  after :all do
    @server.shutdown
  end

  # Use local proxy server in order to avoid side effects, non-working proxies, etc
  before :each do
    proxy = ProxyFetcher::Proxy.new(addr: '127.0.0.1', port: 3128, type: 'HTTP, HTTPS')
    ProxyFetcher::Client::ProxiesRegistry.manager.instance_variable_set(:'@proxies', [proxy])
    allow_any_instance_of(ProxyFetcher::Manager).to receive(:proxies).and_return([proxy])
  end

  context 'GET request with the valid proxy' do
    it 'successfully returns page content for HTTP' do
      content = ProxyFetcher::Client.get('http://httpbin.org')

      expect(content).not_to be_nil
      expect(content).not_to be_empty
    end

    it 'successfully returns page content for HTTPS' do
      content = ProxyFetcher::Client.get('https://httpbin.org')

      expect(content).not_to be_nil
      expect(content).not_to be_empty
    end
  end

  context 'POST request with the valid proxy' do
    it 'successfully returns page content for HTTP' do
      headers = {
        'X-Proxy-Fetcher-Version' => ProxyFetcher::VERSION::STRING
      }
      content = ProxyFetcher::Client.post('http://httpbin.org/post', { param: 'value'} , headers: headers)

      expect(content).not_to be_nil
      expect(content).not_to be_empty

      json = JSON.parse(content)

      expect(json['headers']['X-Proxy-Fetcher-Version']).to eq(ProxyFetcher::VERSION::STRING)
    end

    it 'successfully returns page content for HTTPS' do
      content = ProxyFetcher::Client.post('http://httpbin.org/post', param: 'value')

      expect(content).not_to be_nil
      expect(content).not_to be_empty
    end
  end

  context 'PUT request with the valid proxy' do
    it 'successfully returns page content for HTTP' do
      content = ProxyFetcher::Client.put('http://httpbin.org/put', 'param=PutValue')

      expect(content).not_to be_nil
      expect(content).not_to be_empty

      json = JSON.parse(content)

      expect(json['form']['param']).to eq('PutValue')
    end
  end

  context 'PATCH request with the valid proxy' do
    it 'successfully returns page content for HTTP' do
      content = ProxyFetcher::Client.patch('http://httpbin.org/patch', param: 'value')

      expect(content).not_to be_nil
      expect(content).not_to be_empty

      json = JSON.parse(content)

      expect(json['form']['param']).to eq('value')
    end
  end

  context 'DELETE request with the valid proxy' do
    it 'successfully returns page content for HTTP' do
      content = ProxyFetcher::Client.delete('http://httpbin.org/delete')

      expect(content).not_to be_nil
      expect(content).not_to be_empty
    end
  end

  context 'retries' do
    it 'raises an error when reaches max retries limit' do
      allow(ProxyFetcher::Client::Request).to receive(:execute).and_raise(StandardError)

      expect { ProxyFetcher::Client.get('http://httpbin.org') }.to raise_error(ProxyFetcher::Exceptions::MaximumRetriesReached)
    end
  end

  context 'redirects' do
    it 'follows redirect when present' do
      content = ProxyFetcher::Client.get('http://httpbin.org/absolute-redirect/2')

      expect(content).not_to be_nil
      expect(content).not_to be_empty
    end

    it 'raises an error when reaches max redirects limit' do
      expect { ProxyFetcher::Client.get('http://httpbin.org/absolute-redirect/11') }.to raise_error(ProxyFetcher::Exceptions::MaximumRedirectsReached)
    end
  end
end
