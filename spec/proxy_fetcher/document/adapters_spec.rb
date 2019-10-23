# frozen_string_literal: true

require "spec_helper"

describe ProxyFetcher::Document::Adapters do
  describe "#lookup" do
    it "returns predefined adapters if symbol or string passed" do
      expect(described_class.lookup("nokogiri")).to eq(ProxyFetcher::Document::NokogiriAdapter)

      expect(described_class.lookup(:oga)).to eq(ProxyFetcher::Document::OgaAdapter)
    end

    it "returns self if class passed" do
      expect(described_class.lookup(Struct)).to eq(Struct)
    end

    it "raises an exception if passed value is blank" do
      expect { described_class.lookup(nil) }.to raise_error(ProxyFetcher::Exceptions::BlankAdapter)
      expect { described_class.lookup("") }.to raise_error(ProxyFetcher::Exceptions::BlankAdapter)
    end

    it "raises an exception if adapter doesn't exist" do
      expect { described_class.lookup("wrong") }.to raise_error(ProxyFetcher::Exceptions::UnknownAdapter)
    end
  end
end
