require 'spec_helper'

describe ProxyFetcher::Providers::Base do
  before { ProxyFetcher.config.reset! }
  after { ProxyFetcher.config.reset! }

  it 'does not allows to use not implemented methods' do
    NotImplementedCustomProvider = Class.new(ProxyFetcher::Providers::Base)

    ProxyFetcher::Configuration.register_provider(:provider_without_methods, NotImplementedCustomProvider)
    ProxyFetcher.config.provider = :provider_without_methods

    expect { ProxyFetcher::Manager.new }.to raise_error(NotImplementedError) do |error|
      expect(error.message).to include('load_proxy_list')
    end

    # implement one of the methods
    NotImplementedCustomProvider.class_eval do
      def load_proxy_list(*)
        [1, 2, 3]
      end
    end

    expect { ProxyFetcher::Manager.new }.to raise_error(NotImplementedError) do |error|
      expect(error.message).to include('to_proxy')
    end
  end
end
