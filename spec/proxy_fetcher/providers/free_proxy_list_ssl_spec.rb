require 'spec_helper'

describe ProxyFetcher::Providers::FreeProxyListSSL do
  before :all do
    ProxyFetcher.config.provider = :free_proxy_list_ssl
  end

  it_behaves_like 'a manager'
end
