module ProxyFetcher
  class Document
    class Adapters
      ADAPTER = 'Adapter'.freeze
      private_constant :ADAPTER

      class << self
        def lookup(name_or_class)
          case name_or_class
          when Symbol, String
            adapter_name = name_or_class.to_s.capitalize << ADAPTER
            ProxyFetcher::Document.const_get(adapter_name)
          else
            name_or_class
          end
        rescue NameError
          raise UnknownAdapter, name_or_class
        end
      end
    end
  end
end
