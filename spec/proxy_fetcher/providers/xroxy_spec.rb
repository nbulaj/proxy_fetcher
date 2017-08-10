require 'spec_helper'

describe ProxyFetcher::Providers::XRoxy do
  before :all do
    ProxyFetcher.config.provider = :xroxy
  end

  it_behaves_like 'a manager'
end
