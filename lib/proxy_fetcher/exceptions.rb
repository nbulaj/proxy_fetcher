# frozen_string_literal: true

module ProxyFetcher
  # Base exception class for all the ProxyFetcher exceptions.
  Error = Class.new(StandardError)

  # ProxyFetcher exceptions namespace
  module Exceptions
    # Exception for wrong custom classes (such as ProxyValidator or HTTP Client).
    class WrongCustomClass < Error
      # Initialize new exception
      #
      # @return [WrongCustomClass]
      #
      def initialize(klass, methods)
        required_methods = Array(methods).join(', ')
        super("#{klass} must respond to [#{required_methods}] class methods!")
      end
    end

    # Exception for wrong provider name, that raises when configured provider
    # that is not registered via <code>register_provider</code> interface.
    class UnknownProvider < Error
      # Initialize new exception
      #
      # @param provider_name [String] provider name
      #
      # @return [UnknownProvider]
      #
      def initialize(provider_name)
        super("unregistered proxy provider `#{provider_name}`")
      end
    end

    # Exception for cases when user tries to register already existing provider.
    class RegisteredProvider < Error
      # Initialize new exception
      #
      # @param name [String, Symbol] provider name
      #
      # @return [RegisteredProvider]
      #
      def initialize(name)
        super("`#{name}` provider already registered!")
      end
    end

    # Exception for cases when HTTP client reached maximum count of redirects
    # trying to process HTTP request.
    class MaximumRedirectsReached < Error
      # Initialize new exception
      #
      # @return [MaximumRedirectsReached]
      #
      def initialize(*)
        super('maximum redirects reached')
      end
    end

    # Exception for cases when HTTP client reached maximum count of retries
    # trying to process HTTP request. Can occur when request failed by timeout
    # multiple times.
    class MaximumRetriesReached < Error
      # Initialize new exception
      #
      # @return [MaximumRetriesReached]
      #
      def initialize(*)
        super('reached the maximum number of retries')
      end
    end

    # Exception for cases when user tries to set wrong HTML parser adapter
    # in the configuration.
    class UnknownAdapter < Error
      # Initialize new exception
      #
      # @param name [String] configured adapter name
      #
      # @return [UnknownAdapter]
      #
      def initialize(name)
        super("unknown adapter '#{name}'")
      end
    end

    # Exception for cases when user tries to set <code>nil</code> HTML parser adapter
    # in the configuration (or just forget to change it).
    class BlankAdapter < Error
      # Initialize new exception
      #
      # @return [BlankAdapter]
      #
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
      # Initialize new exception
      #
      # @param adapter_name [String] configured adapter name
      # @param error [String] full setup error (backtrace)
      #
      # @return [AdapterSetupError]
      #
      def initialize(adapter_name, error)
        adapter = demodulize(adapter_name.gsub('Adapter', ''))

        super("can't setup '#{adapter}' adapter during the following error:\n\t#{error}'")
      end

      private

      # Returns just class name removing it's namespace.
      #
      # @param path [String]
      #   full class name
      #
      # @return [String] demodulized class name
      #
      def demodulize(path)
        path = path.to_s
        index = path.rindex('::')

        index ? path[(index + 2)..-1] : path
      end
    end
  end
end
