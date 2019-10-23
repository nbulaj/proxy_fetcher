# frozen_string_literal: true

RSpec.shared_examples "a manager" do
  before :all do
    @cached_manager = ProxyFetcher::Manager.new
  end

  it "loads proxy list on initialization by default" do
    expect(@cached_manager.proxies).not_to be_empty
  end

  it "doesn't load proxy list on initialization if `refresh` argument was set to false" do
    manager = ProxyFetcher::Manager.new(refresh: false)
    expect(manager.proxies).to be_empty
  end

  it "returns valid Proxy objects" do
    expect(@cached_manager.proxies).to all(be_a(ProxyFetcher::Proxy))

    @cached_manager.proxies.each do |proxy|
      expect(proxy.addr).to match(/\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/i)
      expect(proxy.port).to be_a_kind_of(Numeric)
      expect(proxy.type).not_to be_empty
      expect(proxy.country).not_to be_empty
      expect(proxy.anonymity).not_to be_empty
      expect(proxy.response_time).to be_nil.or(be_a_kind_of(Numeric))
    end
  end

  it "returns raw proxies (HOST:PORT)" do
    expect(@cached_manager.raw_proxies).to all(be_a(String))
  end

  it "cleanup proxy list from dead servers" do
    allow_any_instance_of(ProxyFetcher::Proxy).to receive(:connectable?).and_return(false)

    manager = ProxyFetcher::Manager.new

    expect do
      manager.cleanup!
    end.to change { manager.proxies }.to([])
  end

  it "doesn't pollute the output with array of proxies" do
    manager = ProxyFetcher::Manager.new(refresh: false)
    expect(manager.inspect).to eq(manager.to_s)
  end

  it "returns first proxy" do
    manager = ProxyFetcher::Manager.new

    first_proxy = manager.proxies.first

    expect(manager.get).to eq(first_proxy)
    expect(manager.proxies.first).not_to eq(first_proxy)
  end

  it "returns first valid proxy" do
    manager = ProxyFetcher::Manager.new(refresh: false)

    proxies = Array.new(5) { instance_double("ProxyFetcher::Proxy", connectable?: false) }
    manager.instance_variable_set(:@proxies, proxies)

    connectable_proxy = instance_double("ProxyFetcher::Proxy")
    allow(connectable_proxy).to receive(:connectable?).and_return(true)

    manager.proxies[0..2].each { |proxy| proxy.instance_variable_set(:@addr, "192.168.1.1") }
    manager.proxies[2] = connectable_proxy

    expect(manager.get!).to eq(connectable_proxy)
    expect(manager.proxies.size).to be(3)

    expect(manager.get!).to eq(connectable_proxy)
    expect(manager.proxies.size).to be(1)
  end

  it "returns nothing if proxy list is empty" do
    manager = ProxyFetcher::Manager.new(refresh: false)

    expect(manager.get).to be_nil
    expect(manager.get!).to be_nil
  end

  it "returns random proxy" do
    expect(@cached_manager.random).to be_an_instance_of(ProxyFetcher::Proxy)
  end
end
