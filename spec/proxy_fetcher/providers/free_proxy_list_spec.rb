# frozen_string_literal: true

require 'spec_helper'

describe ProxyFetcher::Providers::FreeProxyList do
  before :all do
    ProxyFetcher.configure do |config|
      config.provider = :free_proxy_list
    end
  end

  it_behaves_like 'a manager'
end
