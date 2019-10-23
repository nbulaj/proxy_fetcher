# frozen_string_literal: true

require "spec_helper"

describe ProxyFetcher::Providers::HTTPTunnel do
  before :all do
    ProxyFetcher.config.provider = :http_tunnel
  end

  it_behaves_like "a manager"
end
