# frozen_string_literal: true

require "spec_helper"

describe ProxyFetcher::Providers::FreeProxyListSocks do
  before :all do
    ProxyFetcher.config.provider = :free_proxy_list_socks
  end

  it_behaves_like "a manager"
end
