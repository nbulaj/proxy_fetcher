require 'spec_helper'

describe 'Multiple proxy providers' do
  before { ProxyFetcher.config.reset! }
  after { ProxyFetcher.config.reset! }

  it 'combine proxies from multiple providers' do
    proxy_stub = ProxyFetcher::Proxy.new(addr: '192.168.1.1', port: 8080)

    # Each proxy provider will return 2 proxies
    ProxyFetcher::Configuration.providers_registry.providers.each do |_name, klass|
      allow_any_instance_of(klass).to receive(:load_proxy_list).and_return([1, 2])
      allow_any_instance_of(klass).to receive(:to_proxy).and_return(proxy_stub)
    end

    all_providers = ProxyFetcher::Configuration.registered_providers
    ProxyFetcher.config.providers = all_providers

    expect(ProxyFetcher::Manager.new.proxies.size).to eq(all_providers.size * 2)
  end
end
