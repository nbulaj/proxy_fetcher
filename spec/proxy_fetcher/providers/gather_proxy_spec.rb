# frozen_string_literal: true

require "spec_helper"

describe ProxyFetcher::Providers::GatherProxy, :unreliable do
  before :all do
    ProxyFetcher.config.provider = :gather_proxy
  end

  it_behaves_like "a manager"
end
