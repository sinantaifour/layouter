module Layouter
  module Leaf
    class Spacer < Base

      attr_accessor :min_width, :max_width, :min_height, :max_height

      def initialize
        super(importance: 0)
        @min_width, @min_height = 0, 0
        @max_width, @max_height = Inf, Inf
      end

      def render
        layout!
        [" " * @calculated_width] * @calculated_height
      end

    end
  end
end
