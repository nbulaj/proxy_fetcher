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
      end

      expect { ProxyFetcher.config.http_client = MyHTTPClient }.not_to raise_error
    end

    it 'failed on setup if required methods are missing' do
      MyWrongHTTPClient = Class.new

      expect { ProxyFetcher.config.http_client = MyWrongHTTPClient }
        .to raise_error(ProxyFetcher::Exceptions::WrongCustomClass)
    end
  end

  context 'custom proxy validator' do
    it 'successfully setups if class has all the required methods' do
      class MyProxyValidator
        def self.connectable?(*)
          true
        end
      end

      expect { ProxyFetcher.config.proxy_validator = MyProxyValidator }.not_to raise_error
    end

    it 'failed on setup if required methods are missing' do
      MyWrongProxyValidator = Class.new

      expect { ProxyFetcher.config.proxy_validator = MyWrongProxyValidator }
        .to raise_error(ProxyFetcher::Exceptions::WrongCustomClass)
    end
  end

  context 'custom provider' do
    it 'failed on registration if provider class already registered' do
      expect { ProxyFetcher::Configuration.register_provider(:xroxy, Class.new) }
        .to raise_error(ProxyFetcher::Exceptions::RegisteredProvider)
    end

    it "failed on proxy list fetching if provider doesn't registered" do
      ProxyFetcher.config.provider = :not_existing_provider

      expect { ProxyFetcher::Manager.new }
        .to raise_error(ProxyFetcher::Exceptions::UnknownProvider)
    end
  end
end
