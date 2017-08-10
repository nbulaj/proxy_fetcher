require 'spec_helper'

describe ProxyFetcher::Providers::FreeProxyList do
  before :all do
    ProxyFetcher.config.provider = :free_proxy_list
  end

  it_behaves_like 'a manager'
end
