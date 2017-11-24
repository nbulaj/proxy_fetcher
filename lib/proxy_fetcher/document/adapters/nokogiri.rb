module ProxyFetcher
  class Document
    module Adapters
      class Nokogiri < Abstract
        def self.setup!(*)
          require 'nokogiri'
        end

        def self.parse(data)
          new(::Nokogiri::HTML(data))
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
            node.attr(*args)
          end

          def content_at(*args)
            clear(find(*args).content)
          end

          def content
            node.content
          end

          def html
            node.inner_html
          end
        end
      end
    end
  end
end
