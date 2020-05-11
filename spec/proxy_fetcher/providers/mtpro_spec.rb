# frozen_string_literal: true

require "spec_helper"

describe ProxyFetcher::Providers::MTPro do
  before :all do
    ProxyFetcher.config.provider = :mtpro
  end

  it_behaves_like "a manager"
end
