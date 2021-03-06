require 'asir'

gem 'json'
require 'json/ext'

module ASIR
  class Coder
    # Note: Symbols are not handled.
    # The actual JSON expression is wrapped with an Array.
    class JSON < self
      def _encode obj
        [ obj ].to_json
      end

      def _decode obj
        parser = ::JSON.parser.new(obj)
        ary = parser.parse
        ary.first
      end
    end # class
  end # class
end # module


