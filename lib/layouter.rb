require_relative 'layouter/version'
require_relative 'layouter/errors'
require_relative 'layouter/element'
require_relative 'layouter/parent'
require_relative 'layouter/leaf/base'
require_relative 'layouter/leaf/spacer'
require_relative 'layouter/leaf/annotation'

module Layouter
  class << self
    def rows(*children)
      Parent.new(:rows, children)
    end

    def cols(*children)
      Parent.new(:cols, children)
    end

    def spacer(*args)
      Leaf::Spacer.new(*args)
    end

    def annotation(*args)
      Leaf::Annotation.new(*args)
    end

    def literal(content)
      Leaf::Annotation.new(content, trim: false)
    end
  end
end
