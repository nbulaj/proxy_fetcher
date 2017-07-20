require 'spec_helper'

describe ProxyFetcher::Providers::ProxyDocker do
  before :all do
    ProxyFetcher.config.provider = :proxy_docker
  end

  before do
    html = File.read(File.expand_path('../../../fixtures/proxy_docker.html', __FILE__))
    allow(ProxyFetcher::Providers::Base).to receive(:load_html).and_return(html)
  end

  it_behaves_like 'a manager'
end
