require 'spec_helper'

describe ProxyFetcher::Configuration do
  before { ProxyFetcher.config.reset! }
  after { ProxyFetcher.config.reset! }

  context 'custom HTTP client' do
    it 'successfully setups if class has all the required methods' do
      class MyHTTPClient
        def self.fetch(url)
          url
        end

        def self.connectable?(*)
          true
        end
      end

      expect { ProxyFetcher.config.http_client = MyHTTPClient }.not_to raise_error
    end

    it 'failed on setup if required methods are missing' do
      MyWrongHTTPClient = Class.new

      expect { ProxyFetcher.config.http_client = MyWrongHTTPClient }
        .to raise_error(ProxyFetcher::Configuration::WrongHttpClient)
    end
  end

  context 'custom provider' do
    it 'successfully setups if provider class registered' do
      CustomProvider = Class.new(ProxyFetcher::Providers::Base)
      ProxyFetcher::Configuration.register_provider(:custom_provider, CustomProvider)

      expect { ProxyFetcher.config.provider = :custom_provider }.not_to raise_error
    end

    it 'failed on setup if provider class is not registered' do
      expect { ProxyFetcher.config.provider = :unexisting_provider }
        .to raise_error(ProxyFetcher::Configuration::UnknownProvider)
    end

    it 'failed on setup if provider class already registered' do
      expect { ProxyFetcher::Configuration.register_provider(:xroxy, Class.new)}
        .to raise_error(ProxyFetcher::Configuration::RegisteredProvider)
    end
  end
end
