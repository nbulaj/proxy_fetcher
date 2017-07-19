require 'spec_helper'

describe ProxyFetcher::Providers::FreeProxyList do
  before :all do
    ProxyFetcher.config.provider = :free_proxy_list
  end

  before do
    html = File.read(File.expand_path('../../../fixtures/free_proxy_list.html', __FILE__))
    allow(ProxyFetcher::Providers::Base).to receive(:load_html).and_return(html)
  end

  it_behaves_like 'a manager'
end
