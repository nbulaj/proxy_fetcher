require 'spec_helper'

describe ProxyFetcher::Providers::GatherProxy do
  before :all do
    ProxyFetcher.config.provider = :gather_proxy
  end

  it_behaves_like 'a manager'
end
