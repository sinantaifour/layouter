module Layouter
  module Leaf
    class Base < Element

      attr_reader :importance

      def initialize(importance:)
        super()
        if !importance.is_a?(Numeric) || importance < 0
          raise(ArgumentError, "Invalid importance")
        end
        @importance = importance == 0 ? Float::EPSILON : importance
      end

      def layout(width, height)
        unless min_width <= width && width <= max_width
          raise(LayoutError.new(:width, :out_of_range))
        end
        unless min_height <= height && height <= max_height
          raise(LayoutError.new(:height, :out_of_range))
        end
        @calculated_width, @calculated_height = width, height
      end

    end
  end
end
