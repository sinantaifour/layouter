module Layouter
  module Leaf
    class Annotation < Base

      attr_accessor :min_width, :max_width, :min_height, :max_height

      def initialize(content, importance: 1)
        super(importance: importance)
        unless content.is_a?(Numeric) || content.is_a?(String)
          raise(ArgumentError, "Must be a number or strings") 
        end
        @content = content
        @min_width = @max_width = @content.to_s.length # TODO: make smarter.
        @min_height = @max_height = 1
      end

      def render
        [@content.to_s]
      end

    end
  end
end
