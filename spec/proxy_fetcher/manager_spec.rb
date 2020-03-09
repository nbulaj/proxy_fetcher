# frozen_string_literal: true

require "spec_helper"

describe ProxyFetcher::Manager do
  it "can initialize with a proxies from file(s)" do
    manager = described_class.new(refresh: false, file: "spec/fixtures/proxies.txt")

    expect(manager.proxies.size).to be(14)

    manager = described_class.new(
      refresh: false,
      file: ["spec/fixtures/proxies.txt", "spec/fixtures/proxies.txt"]
    )

    expect(manager.proxies.size).to be(14)
  end
end
