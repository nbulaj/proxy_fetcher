require 'spec_helper'

describe ProxyFetcher::Providers::Hidster do
  before :all do
    ProxyFetcher.config.provider = :hidster
  end

  before do
    html = File.read(File.expand_path('../../../fixtures/hidster.html', __FILE__))
    allow(ProxyFetcher::Providers::Base).to receive(:load_html).and_return(html)
  end

  it_behaves_like 'a manager'
end
