module Layouter
  class Parent < Element

    DIM = {
      rows: :height,
      cols: :width,
    }.freeze

    def initialize(orientation, children)
      unless DIM.keys.include?(orientation)
        raise(ArgumentError.new("Invalid orientation"))
      end
      unless children.is_a?(Array) && children.all? { |c| c.is_a?(Element) }
        raise(ArgumentError.new("Invalid chidlren"))
      end
      @orientation = orientation
      @children = children
    end

    def [](index)
      @children[index]
    end

    def layout(width, height)
      dim = DIM[@orientation]
      value = binding.local_variable_get(dim)
      min, max = send(:"min_#{dim}"), send(:"max_#{dim}")
      raise(LayoutError.new(dim, :inconsistent)) if min > max
      raise(LayoutError.new(dim, :too_small)) unless value >= min
      raise(LayoutError.new(dim, :too_big)) unless value <= max
      importances = @children.map(&:importance)
      maxs = @children.map { |c| c.send(:"max_#{dim}") - c.send(:"min_#{dim}") }
      extras = self.class.distribute(value - min, importances, maxs)
      @children.zip(extras).each do |child, extra|
        child.layout(
          dim == :width ? child.min_width + extra : width,
          dim == :height ? child.min_height + extra : height,
        )
      end
      @calculated_width, @calculated_height = width, height
      self
    end

    [:width, :height].each do |dim|
      define_method(:"min_#{dim}") do
        mins = @children.map(&:"min_#{dim}")
        DIM[@orientation] == dim ? mins.sum : mins.max
      end
      define_method(:"max_#{dim}") do
        maxs = @children.map(&:"max_#{dim}")
        DIM[@orientation] == dim ? maxs.sum : maxs.min
      end
    end

    def importance
      @children.map(&:importance).max
    end

    def render
      layout!
      if @orientation == :rows
        @children.map { |child| child.render }.flatten
      elsif @orientation == :cols
        children = @children.map(&:render)
        (0...@calculated_height).map do |i|
          children.map { |child| child[i] }.join("")
        end
      end
    end

    def self.distribute(rem, importances, maxs)
      res = []
      # Distribute based on the importance, adhering to the maxs
      tuples = (0...importances.length).zip(importances.map(&:to_f))
      while !tuples.empty?
        sum = tuples.map(&:last).sum
        tuples = tuples.map { |index, value| [index, value * rem / sum] }
        break if tuples.all? { |index, value| value <= maxs[index] }
        tuples = tuples.reject do |index, value|
          if maxs[index] <= value
            res << [index, maxs[index]]
            rem -= maxs[index]
            next true
          end
          false
        end
      end
      res += tuples
      # Turn into integers, filling up any extra or missing value.
      diff = res.map(&:last).sum.to_i - res.map(&:last).map(&:to_i).sum
      res = res.sort_by(&:first).map(&:last).map(&:to_i)
      tuples = (0...importances.length).zip(importances.map(&:to_f))
      tuples = tuples.sort_by(&:last)
      tuples = tuples.reverse if diff > 0
      delta = diff > 0 ? 1 : -1
      tuples.cycle do |index, _|
        break if diff == 0
        res[index] += delta
        diff -= delta
      end
      res
    end

  end
end
