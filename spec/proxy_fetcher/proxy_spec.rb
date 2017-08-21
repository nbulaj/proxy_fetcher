require 'spec_helper'

describe ProxyFetcher::Proxy do
  before :all do
    ProxyFetcher.config.provider = :hide_my_name
  end

  before do
    @manager = ProxyFetcher::Manager.new
  end

  let(:proxy) { @manager.proxies.first.dup }

  it 'checks schema' do
    proxy.type = ProxyFetcher::Providers::Base::HTTP
    expect(proxy.http?).to be_truthy
    expect(proxy.https?).to be_falsey

    proxy.type = ProxyFetcher::Providers::Base::HTTPS
    expect(proxy.https?).to be_truthy
    expect(proxy.http?).to be_falsey
  end

  it 'not connectable if IP addr is wrong' do
    proxy.addr = '192.168.1.0'
    expect(proxy.connectable?).to be_falsey
  end

  it 'not connectable if there are some error during connection request' do
    allow_any_instance_of(Net::HTTP).to receive(:start).and_raise(Errno::ECONNABORTED)
    expect(proxy.connectable?).to be_falsey
  end

  it "not connectable if server doesn't respond to head" do
    allow_any_instance_of(Net::HTTP).to receive(:start).and_return(false)
    expect(proxy.connectable?).to be_falsey
    expect(proxy.valid?).to be_falsey
  end

  it 'returns URI::Generic' do
    expect(proxy.uri).to be_a(URI::Generic)
  end

  it 'returns URL' do
    expect(proxy.url).to be_a(String)
  end

  it 'checks speed' do
    proxy.speed = :fast
    expect(proxy.fast?).to be_truthy

    proxy.speed = :slow
    expect(proxy.slow?).to be_truthy

    proxy.speed = :medium
    expect(proxy.medium?).to be_truthy
  end
end
