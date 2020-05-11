# frozen_string_literal: true

require "spec_helper"

describe ProxyFetcher::Providers::Proxypedia do
  before :all do
    ProxyFetcher.config.provider = :proxypedia
  end

  it_behaves_like "a manager"
end
