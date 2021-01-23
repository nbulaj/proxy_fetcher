# frozen_string_literal: true

require "spec_helper"

describe ProxyFetcher::Providers::ProxyscrapeSOCKS4 do
  before :all do
    ProxyFetcher.config.provider = :proxyscrape_socks4
  end

  it_behaves_like "a manager"
end
