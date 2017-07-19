require 'spec_helper'

describe ProxyFetcher::Providers::HideMyAss do
  before :all do
    ProxyFetcher.config.provider = :hide_my_ass
  end

  before do
    html = File.read(File.expand_path('../../../fixtures/hide_my_ass.html', __FILE__))
    allow(ProxyFetcher::Providers::Base).to receive(:load_html).and_return(html)
  end

  it_behaves_like 'a manager'
end
