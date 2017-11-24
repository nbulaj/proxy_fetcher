module ProxyFetcher
  class Document
    module Adapters
      class Abstract
        attr_reader :doc

        def initialize(doc)
          @doc = doc
        end

        # You can override this method in you class
        def xpath(selector)
          doc.xpath(selector)
        end

        # You can override this method in you class
        def css(selector)
          doc.css(selector)
        end

        def proxy_node
          ::ProxyFetcher::Document::Node
        end
      end
    end
  end
end
