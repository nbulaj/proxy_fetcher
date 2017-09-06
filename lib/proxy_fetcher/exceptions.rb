module ProxyFetcher
  Error = Class.new(StandardError)

  module Exceptions
    class WrongCustomClass < Error
      def initialize(klass, methods)
        required_methods = Array(methods).join(', ')
        super("#{klass} must respond to [#{required_methods}] class methods!")
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
      def initialize(*)
        super('maximum redirects reached')
      end
    end

    class MaximumRetriesReached < Error
      def initialize(*)
        super('reached the maximum number of retries')
      end
    end
  end
end
