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

    class UnknownAdapter < Error
      def initialize(name)
        super("unknown adapter '#{name}'")
      end
    end

    class BlankAdapter < Error
      def initialize(*)
        super(<<-MSG.strip.squeeze
          you need to specify adapter for HTML parsing: ProxyFetcher.config.adapter = :nokogiri.
          You can use one of the predefined adapters (:nokogiri or :oga) or your own implementation.
          MSG
        )
      end
    end

    class AdapterSetupError < Error
      def initialize(adapter_name, reason)
        adapter = demodulize(adapter_name.remove('Adapter'))

        super("can't setup '#{adapter}' adapter during the following error:\n\t#{reason}'")
      end

      private

      def demodulize(path)
        path = path.to_s
        index = path.rindex('::')

        if index
          path[(index + 2)..-1]
        else
          path
        end
      end
    end
  end
end
