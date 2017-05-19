require 'spec_helper'

describe Proxifier::Proxy do
  before :all do
    @manager = Proxifier::Manager.new
  end

  let(:proxy) { @manager.proxies.first }

  it 'checks schema' do
    expect(proxy.http?).to be_falsey.or(be_truthy)
    expect(proxy.https?).to be_falsey.or(be_truthy)
  end

  it 'checks connection status' do
    allow_any_instance_of(Proxifier::Proxy).to receive(:addr).and_return('192.168.1.1')
    expect(proxy.connectable?).to be_falsey
  end

  it 'returns URI::Generic' do
    expect(proxy.uri).to be_a(URI::Generic)
  end

  it 'returns URL' do
    expect(proxy.url).to be_a(String)
  end
end
