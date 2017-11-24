module ProxyFetcher
  class Document
    module Adapters
      class Oga < Abstract
        def self.setup!(*)
          require 'oga'
        end

        def self.parse(data)
          new(::Oga.parse_html(data))
        end

        def proxy_node
          Node
        end

        class Node < ProxyFetcher::Document::Node
          def at_xpath(*args)
            self.class.new(node.at_xpath(*args))
          end

          def at_css(*args)
            self.class.new(node.at_css(*args))
          end

          def attr(*args)
            node.attribute(*args).value
          end

          def content_at(*args)
            clear(find(*args).content)
          end

          def content
            node.text
          end

          def html
            node.to_xml
          end
        end
      end
    end
  end
end
