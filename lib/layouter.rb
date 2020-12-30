require_relative 'layouter/version'
require_relative 'layouter/errors'
require_relative 'layouter/element'
require_relative 'layouter/parent'
require_relative 'layouter/leaf/base'
require_relative 'layouter/leaf/spacer'

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
  end
end
