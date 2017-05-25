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

  it "doesn't pollute the output with array of proxies" do
    manager = described_class.new(refresh: false)
    expect(manager.inspect).to eq(manager.to_s)
  end

  it 'returns first proxy' do
    manager = described_class.new

    first_proxy = manager.proxies.first

    expect(manager.get).to eq(first_proxy)
    expect(manager.proxies.first).not_to eq(first_proxy)
  end

  it 'returns first valid proxy' do
    manager = described_class.new(refresh: false)

    proxies = 5.times.collect { instance_double('ProxyFetcher::Proxy', connectable?: false) }
    manager.instance_variable_set(:@proxies, proxies)

    connectable_proxy = instance_double('ProxyFetcher::Proxy')
    allow(connectable_proxy).to receive(:connectable?).and_return(true)

    manager.proxies[0..2].each { |proxy| proxy.instance_variable_set(:@addr, '192.168.1.1') }
    manager.proxies[2] = connectable_proxy

    expect(manager.get!).to eq(connectable_proxy)
    expect(manager.proxies.size).to be(3)

    expect(manager.get!).to eq(connectable_proxy)
    expect(manager.proxies.size).to be(1)
  end

  it 'returns nothing if proxy list is empty' do
    manager = described_class.new(refresh: false)

    expect(manager.get).to be_nil
    expect(manager.get!).to be_nil
  end
end
