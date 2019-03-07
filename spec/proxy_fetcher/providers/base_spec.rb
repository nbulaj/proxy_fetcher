# frozen_string_literal: true

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

  it 'logs failed to load proxy providers' do
    CustomProvider = Class.new(ProxyFetcher::Providers::Base) do
      def load_proxy_list(*)
        doc = load_document('https://google.com', {})
        doc.xpath('//table[contains(@class, "table")]/tr[(not(@id="proxy-table-header")) and (count(td)>2)]')
      end
    end

    logger = Logger.new(StringIO.new)

    ProxyFetcher::Configuration.register_provider(:custom_provider, CustomProvider)
    ProxyFetcher.config.provider = :custom_provider
    ProxyFetcher.config.logger = logger

    allow_any_instance_of(HTTP::Client).to receive(:get).and_raise(StandardError)

    expect(logger).to receive(:warn).with(/Failed to process request to http[s:\/]/)

    ProxyFetcher::Manager.new
  end
end
