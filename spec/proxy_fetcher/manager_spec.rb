require 'spec_helper'

describe ProxyFetcher::Manager do
  it 'loads proxy list on initialization by default' do
    manager = described_class.new
    expect(manager.proxies).not_to be_empty
  end

  it "doesn't load proxy list on initialization if `refresh` argument was set to false" do
    manager = described_class.new(refresh: false)
    expect(manager.proxies).to be_empty
  end

  it 'can returns Proxy objects' do
    manager = described_class.new
    expect(manager.proxies).to all(be_a(ProxyFetcher::Proxy))
  end

  it 'can returns raw proxies' do
    manager = described_class.new
    expect(manager.raw_proxies).to all(be_a(String))
  end

  it 'cleanup proxy list from dead servers' do
    allow_any_instance_of(ProxyFetcher::Proxy).to receive(:connectable?).and_return(false)

    manager = described_class.new

    expect { manager.cleanup! }.to change { manager.proxies }.to([])
  end
end
