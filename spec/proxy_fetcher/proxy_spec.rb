# frozen_string_literal: true

require 'spec_helper'

describe ProxyFetcher::Proxy do
  before :all do
    ProxyFetcher.config.provider = :proxy_docker
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
    expect(proxy.ssl?).to be_falsey

    proxy.type = ProxyFetcher::Proxy::HTTPS
    expect(proxy.https?).to be_truthy
    expect(proxy.http?).to be_truthy
    expect(proxy.ssl?).to be_truthy

    proxy.type = ProxyFetcher::Proxy::SOCKS4
    expect(proxy.socks4?).to be_truthy
    expect(proxy.ssl?).to be_truthy

    proxy.type = ProxyFetcher::Proxy::SOCKS5
    expect(proxy.socks5?).to be_truthy
    expect(proxy.ssl?).to be_truthy
  end

  it 'not connectable if IP addr is wrong' do
    proxy.addr = '192.168.1.0'
    expect(proxy.connectable?).to be_falsey
  end

  it 'not connectable if there are some error during connection request' do
    allow_any_instance_of(HTTP::Client).to receive(:get).and_raise(HTTP::TimeoutError)
    expect(proxy.connectable?).to be_falsey
  end

  it 'returns URI::Generic' do
    expect(proxy.uri).to be_a(URI::Generic)

    expect(proxy.uri.host).not_to be_empty
    expect(proxy.uri.port).not_to be_nil
  end

  it 'returns URL' do
    expect(proxy.url).to be_a(String)
  end

  it 'returns URL with scheme' do
    expect(proxy.url(scheme: true)).to include('://')
  end
end
