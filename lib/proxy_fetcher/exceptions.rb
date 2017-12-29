# frozen_string_literal: true

module ProxyFetcher
  # Base exception class for all the ProxyFetcher exceptions.
  Error = Class.new(StandardError)

  # ProxyFetcher exceptions namespace
  module Exceptions
    # Exception for wrong custom classes (such as ProxyValidator or HTTP Client).
    class WrongCustomClass < Error
      def initialize(klass, methods)
        required_methods = Array(methods).join(', ')
        super("#{klass} must respond to [#{required_methods}] class methods!")
      end
    end

    # Exception for wrong provider name, that raises when configured provider
    # that is not registered via <code>register_provider</code> interface.
    class UnknownProvider < Error
      def initialize(provider_name)
        super("unregistered proxy provider `#{provider_name}`")
      end
    end

    # Exception for cases when user tries to register already existing provider.
    class RegisteredProvider < Error
      def initialize(name)
        super("`#{name}` provider already registered!")
      end
    end

    # Exception for cases when HTTP client reached maximum count of redirects
    # trying to process HTTP request.
    class MaximumRedirectsReached < Error
      def initialize(*)
        super('maximum redirects reached')
      end
    end

    # Exception for cases when HTTP client reached maximum count of retries
    # trying to process HTTP request. Can occur when request failed by timeout
    # multiple times.
    class MaximumRetriesReached < Error
      def initialize(*)
        super('reached the maximum number of retries')
      end
    end

    # Exception for cases when user tries to set wrong HTML parser adapter
    # in the configuration.
    class UnknownAdapter < Error
      def initialize(name)
        super("unknown adapter '#{name}'")
      end
    end

    # Exception for cases when user tries to set <code>nil</code> HTML parser adapter
    # in the configuration (or just forget to change it).
    class BlankAdapter < Error
      def initialize(*)
        super(<<-MSG.strip.squeeze
          you need to specify adapter for HTML parsing: ProxyFetcher.config.adapter = :nokogiri.
          You can use one of the predefined adapters (:nokogiri or :oga) or your own implementation.
          MSG
        )
      end
    end

    # Exception for cases when HTML parser adapter can't be installed.
    # It will print the reason (backtrace) of the exception that caused an error.
    class AdapterSetupError < Error
      def initialize(adapter_name, reason)
        adapter = demodulize(adapter_name.gsub('Adapter', ''))

        super("can't setup '#{adapter}' adapter during the following error:\n\t#{reason}'")
      end

      private

      def demodulize(path)
        path = path.to_s
        index = path.rindex('::')

        index ? path[(index + 2)..-1] : path
      end
    end
  end
end
