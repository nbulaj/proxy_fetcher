# frozen_string_literal: true

module ProxyFetcher
  class Document
    # ProxyFetcher HTML parser adapters.
    #
    # ProxyFetcher default supported adapters are:
    #
    # * Nokogiri
    # * Oga
    #
    # Any custom adapter can be used and must be inherited from
    # <code>ProxyFetcher::Document::AbstractAdapter</code>.
    class Adapters
      # Adapters class name suffix
      ADAPTER = 'Adapter'.freeze
      private_constant :ADAPTER

      class << self
        # Returns HTML parser adapter by it's name or class.
        # If name is provided, then it looks for predefined classes
        # in <code>ProxyFetcher::Document</code> namespace. Otherwise
        # it just returns the passed class.
        #
        # @param name_or_class [String, Class]
        #   Adapter name or class
        #
        def lookup(name_or_class)
          raise Exceptions::BlankAdapter if name_or_class.nil? || name_or_class.to_s.empty?

          case name_or_class
          when Symbol, String
            adapter_name = name_or_class.to_s.capitalize << ADAPTER
            ProxyFetcher::Document.const_get(adapter_name)
          else
            name_or_class
          end
        rescue NameError
          raise Exceptions::UnknownAdapter, name_or_class
        end
      end
    end
  end
end
