module Layouter
  module Leaf
    class Annotation < Base

      ALMOST = "~"
      ELLIPSIS = "\u2026"

      attr_accessor :min_height, :max_height

      def initialize(content, importance: 1, trim: true)
        super(importance: importance)
        unless content.is_a?(Numeric) || content.is_a?(String)
          raise(ArgumentError, "Must be a number or strings") 
        end
        @content = content
        @trim = trim
        @min_width = @max_width = @content.to_s.length # TODO: make smarter.
        @min_height = @max_height = 1
      end

      def min_width
        if @trim && @content.is_a?(String)
          2
        elsif @trim && @content.is_a?(Numeric)
          dot = @content.to_s.index(".")
          dot ? dot + 1 : @content.to_s.length
        else
          @content.to_s.length
        end
      end

      def max_width
        @content.to_s.length
      end

      def render
        layout!
        if @calculated_width == @content.to_s.length
          @content.to_s
        elsif @content.is_a?(String)
          @content[0...(@calculated_width - 1)] + ELLIPSIS
        elsif @content.is_a?(Numeric)
          ALMOST + @content.to_s[0...(@calculated_width - 1)]
        end
      end

    end
  end
end
