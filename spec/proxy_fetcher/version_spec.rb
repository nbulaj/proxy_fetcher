# frozen_string_literal: true

RSpec.describe ProxyFetcher::VERSION do
  it { expect(ProxyFetcher::VERSION::STRING).to match(/^\d+\.\d+\.\d+(\.\w+)?$/) }
end
