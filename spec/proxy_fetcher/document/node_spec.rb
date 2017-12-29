# frozen_string_literal: true

require 'spec_helper'

describe ProxyFetcher::Document::Node do
  context 'overridable methods' do
    it 'raises an error' do
      node = ProxyFetcher::Document::Node.new('')

      %w[content html].each do |method|
        expect { node.public_send(method) }.to raise_error do |error|
          expect(error.message).to include("`#{method}` must be implemented")
        end
      end
    end
  end
end
