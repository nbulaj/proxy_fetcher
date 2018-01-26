# frozen_string_literal: true

require 'spec_helper'

describe ProxyFetcher::Client::ProxiesRegistry do
  context '#manager' do
    it 'instantiates ProxyFetcher::Manager instance' do
      expect(described_class.manager).not_to be_nil
      expect(described_class.manager).to be_an_instance_of(ProxyFetcher::Manager)
    end

    it 'caches manager instance' do
      expect(described_class.manager).to eq(described_class.manager)
    end
  end

  context '#invalidate_proxy!' do
    it 'removes proxy from the list' do
      proxy = described_class.manager.proxies.first
      described_class.invalidate_proxy!(proxy)

      expect(described_class.manager.proxies).not_to include(proxy)
    end

    it 'refreshes the list if it is empty' do
      proxy = described_class.manager.proxies.first
      described_class.manager.instance_variable_set(:'@proxies', [proxy])

      described_class.invalidate_proxy!(proxy)

      expect(described_class.manager.proxies.count).to be > 1
    end
  end

  context '#find_proxy_for' do
    it 'searches for specific proxy based on URL schema type' do
      expect(described_class.find_proxy_for('http://google.com')).not_to be_nil

      proxy = described_class.find_proxy_for('https://google.com')
      expect(proxy.ssl?).to be_truthy
    end
  end
end
