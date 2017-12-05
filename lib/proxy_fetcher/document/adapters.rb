module ProxyFetcher
  class Document
    class Adapters
      ADAPTER = 'Adapter'.freeze
      private_constant :ADAPTER

      class << self
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
