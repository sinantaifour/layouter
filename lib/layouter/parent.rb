module Layouter
  class Parent < Element

    DIM = {
      rows: :height,
      cols: :width,
    }.freeze

    def initialize(orientation, children)
      super()
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
        @children.map(&:render).join("\n")
      elsif @orientation == :cols
        tmp = @children.map { |child| child.render.split("\n") }
        tmp[0].zip(*tmp[1..-1]).map(&:join).join("\n")
      end
    end

    def self.distribute(value, importances, maxs)
      raise(AssertionError) unless value.is_a?(Integer) # Avoid endless loops.
      raise(AssertionError) unless value <= maxs.sum # Avoid endless loops.
      raise(AssertionError) unless importances.length == maxs.length
      unless maxs.all? { |v| v.is_a?(Integer) || v == Float::INFINITY }
        raise(AssertionError)
      end
      data = importances.zip(maxs).map.with_index do |(importance, max), i|
        { index: i, value: 0, importance: importance, max: max }
      end
      while true # Distribute based on the importance, adhering to the maxs.
        extra = value - data.map { |h| h[:value] }.sum
        break if extra <= Float::EPSILON * data.length
        candidates = data.select { |h| h[:value] < h[:max] }
        denominator = candidates.map { |h| h[:importance] }.sum.to_f
        candidates.each do |h|
          share = extra * h[:importance] / denominator
          h[:value] = h[:value] + share > h[:max] ? h[:max] : h[:value] + share
        end
      end
      data.each { |h| h[:value] = h[:value].round }
      while true # Fill up any extra or missing value from turning to integers.
        extra = value - data.map { |h| h[:value] }.sum
        break if extra == 0
        delta = extra > 0 ? 1 : -1
        data = data.sort_by { |h| h[:importance] }
        data = data.reverse if extra > 0
        data.cycle do |h|
          if h[:max] > h[:value] && h[:value] > 0
            h[:value] += delta
            extra -= delta
            break if extra == 0
          end
        end
      end
      raise(AssertionError) unless data.map { |h| h[:value] }.sum == value
      raise(AssertionError) unless data.all? { |h| h[:value] <= h[:max] }
      data.sort_by { |h| h[:index] }.map { |h| h[:value] }
    end

  end
end
