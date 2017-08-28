require 'spec_helper'

describe ProxyFetcher::Proxy do
  before :all do
    ProxyFetcher.config.provider = :hide_my_name
  end

  before do
    @manager = ProxyFetcher::Manager.new
  end

  let(:proxy) { @manager.proxies.first.dup }

  it 'can initialize a new proxy object' do
    proxy = described_class.new(addr: '192.169.1.1', port: 8080, type: 'HTTP')

    expect(proxy).not_to be_nil
    expect(proxy.addr).to eq('192.169.1.1')
    expect(proxy.port).to eq(8080)
    expect(proxy.type).to eq('HTTP')
  end

  it 'checks schema' do
    proxy.type = ProxyFetcher::Proxy::HTTP
    expect(proxy.http?).to be_truthy
    expect(proxy.https?).to be_falsey

    proxy.type = ProxyFetcher::Proxy::HTTPS
    expect(proxy.https?).to be_truthy
    expect(proxy.http?).to be_truthy

    proxy.type = ProxyFetcher::Proxy::SOCKS5
    expect(proxy.socks5?).to be_truthy
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
end
