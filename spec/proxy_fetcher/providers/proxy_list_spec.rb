# frozen_string_literal: true

require "spec_helper"

describe ProxyFetcher::Providers::ProxyList do
  before :all do
    ProxyFetcher.config.provider = :proxy_list
  end

  it_behaves_like "a manager"
end
