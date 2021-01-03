module Layouter
  module Leaf
    class Custom < Base

      attr_reader :min_width, :max_width, :min_height, :max_height

      def initialize(width: (0..INF), height: (0..INF), importance: 1, &block)
        super(importance: importance)
        [:width, :height].each do |dim|
          eval <<-CODE, binding, __FILE__ , __LINE__ + 1
            if #{dim}.is_a?(Integer)
              @min_#{dim} = @max_#{dim} = #{dim}
            elsif #{dim}.is_a?(Range) && #{dim}.first.is_a?(Integer)
              @min_#{dim} = #{dim}.first
              @max_#{dim} = #{dim}.exclude_end? ? #{dim}.last - 1 : #{dim}.last
            else
              raise(ArgumentError.new("Invalid #{dim}"))
            end
            if @min_#{dim} > @max_#{dim}
              raise(ArgumentError.new("Inconsistent minimum and maximum #{dim}"))
            end
          CODE
        end
        raise(ArgumentError.new("Must pass block")) unless block_given?
        @block = block
      end

      def render
        layout!
        w, h = @calculated_width, @calculated_height
        res = @block.call(w, h)
        lines = res.split("\n")
        if lines.length != h || !lines.all? { |l| l.length == w }
          raise(ArgumentError.new("Custom render has incorrect dimensions"))
        end
        res
      end

    end
  end
end
