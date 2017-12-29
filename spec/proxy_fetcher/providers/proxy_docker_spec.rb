# frozen_string_literal: true

require 'spec_helper'

describe ProxyFetcher::Providers::ProxyDocker do
  before :all do
    ProxyFetcher.config.provider = :proxy_docker
  end

  it_behaves_like 'a manager'
end
