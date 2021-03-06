module Layouter
  module Leaf
    class Spacer < Base

      attr_accessor :min_width, :max_width, :min_height, :max_height

      def initialize(weight: 1)
        unless weight.is_a?(Numeric)
          raise(ArgumentError, "Weight must be a number")
        end
        raise(ArgumentError, "Weight must more than 1") if weight < 1
        super(importance: EPS * weight)
        @min_width = @min_height = 0
        @max_width = @max_height = INF
      end

      def render
        layout!
        ([" " * @calculated_width] * @calculated_height).join("\n")
      end

    end
  end
end
