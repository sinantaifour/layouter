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
        # These layout errors could occur in the dimension not being
        # distributed by the parent, or if the leaf is layed our directly.
        raise(LayoutError.new(:width, :too_small)) if width < min_width
        raise(LayoutError.new(:width, :too_big)) if width > max_width
        raise(LayoutError.new(:height, :too_small)) if height < min_height
        raise(LayoutError.new(:height, :too_big)) if height > max_height
        @calculated_width, @calculated_height = width, height
      end

    end
  end
end
