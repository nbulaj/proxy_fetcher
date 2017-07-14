require 'spec_helper'

describe ProxyFetcher::Proxy do
  before :all do
    ProxyFetcher.config.provider = :hide_my_ass
  end

  before do
    html = File.read(File.expand_path('../../../../fixtures/hide_my_ass.html', __FILE__))
    allow(ProxyFetcher::Providers::Base).to receive(:load_html).and_return(html)

    @manager = ProxyFetcher::Manager.new
  end

  let(:proxy) { @manager.proxies.first }

  it 'checks schema' do
    proxy.instance_variable_set(:@type, 'HTTP')
    expect(proxy.http?).to be_truthy
    expect(proxy.https?).to be_falsey

    proxy.instance_variable_set(:@type, 'HTTPS')
    expect(proxy.https?).to be_truthy
    expect(proxy.http?).to be_falsey
  end

  it 'not connectable if IP addr is wrong' do
    allow_any_instance_of(ProxyFetcher::Proxy).to receive(:addr).and_return('192.168.1.1')
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

  it 'must be slow if speed < 33' do
    proxy.instance_variable_set(:@speed, 32)
    expect(proxy.slow?).to be_truthy

    proxy.instance_variable_set(:@speed, 33)
    expect(proxy.slow?).to be_falsey
  end

  it 'must be medium if speed >= 33 and < 66' do
    proxy.instance_variable_set(:@speed, 32)
    expect(proxy.medium?).to be_falsey

    proxy.instance_variable_set(:@speed, 33)
    expect(proxy.medium?).to be_truthy

    proxy.instance_variable_set(:@speed, 65)
    expect(proxy.medium?).to be_truthy
  end

  it 'must be fast if speed >= 66' do
    proxy.instance_variable_set(:@speed, 65)
    expect(proxy.fast?).to be_falsey

    proxy.instance_variable_set(:@speed, 66)
    expect(proxy.fast?).to be_truthy
  end
end
