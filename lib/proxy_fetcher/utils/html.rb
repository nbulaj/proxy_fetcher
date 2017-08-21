module ProxyFetcher
  class HTML
    class << self
      def clear(text)
        return if text.nil? || text.empty?

        text.strip.gsub(/[ \t]/i, '')
      end

      def convert_to_int(text)
        Integer(clear(text))
      end
    end
  end
end
