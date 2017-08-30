module ProxyFetcher
  Error = Class.new(StandardError)

  module Exceptions
    class WrongCustomClass < Error
      def initialize(klass, methods)
        super("#{klass} must respond to [#{methods}] class methods!")
      end
    end

    class UnknownProvider < Error
      def initialize(provider_name)
        super("unregistered proxy provider `#{provider_name}`")
      end
    end

    class RegisteredProvider < Error
      def initialize(name)
        super("`#{name}` provider already registered!")
      end
    end

    class MaximumRedirectsReached < Error
      def message
        'maximum redirects reached'
      end
    end

    class MaximumRetriesReached < Error
      def message
        'reached the maximum number of retries'
      end
    end
  end
end
