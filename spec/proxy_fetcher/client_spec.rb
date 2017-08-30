require 'spec_helper'

describe ProxyFetcher::Client do
  before :all do
    ProxyFetcher.config.provider = :hide_my_name

    local_proxy_server = File.expand_path('../../local_proxy_server.rb', __FILE__)
    @pid = Process.spawn("ruby #{local_proxy_server}")
  end

  after :all do
    Process.kill('TERM', @pid)
  end

  before :each do
    proxy = ProxyFetcher::Proxy.new(addr: '127.0.0.1', port: 3128, type: 'HTTP, HTTPS')
    allow(ProxyFetcher::Client::ProxiesRegistry).to receive(:find_proxy_for).and_return(proxy)
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
      content = ProxyFetcher::Client.post('http://httpbin.org/post', { param: 'value' })

      expect(content).not_to be_nil
      expect(content).not_to be_empty
    end

    it 'successfully returns page content for HTTPS' do
      content = ProxyFetcher::Client.post('http://httpbin.org/post', { param: 'value' })

      expect(content).not_to be_nil
      expect(content).not_to be_empty
    end
  end

  context 'retries' do
    it 'reaches max limit' do
      allow(ProxyFetcher::Client::Request).to receive(:execute).and_raise(StandardError)

      expect { ProxyFetcher::Client.get('http://httpbin.org') }.to raise_error(ProxyFetcher::Client::MaximumRetriesReached)
    end
  end

  context 'redirects' do
    it 'follows redirects' do
      content = ProxyFetcher::Client.get('http://httpbin.org/absolute-redirect/2')

      expect(content).not_to be_nil
      expect(content).not_to be_empty
    end

    xit 'reaches max limit' do
      expect { ProxyFetcher::Client.get('http://httpbin.org/absolute-redirect/11') }.to raise_error
    end
  end
end
