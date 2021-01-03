require_relative 'layouter/version'
require_relative 'layouter/errors'
require_relative 'layouter/element'
require_relative 'layouter/parent'
require_relative 'layouter/leaf/base'
require_relative 'layouter/leaf/spacer'
require_relative 'layouter/leaf/annotation'
require_relative 'layouter/leaf/custom'

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
      annotation(content, trim: false)
    end

    def custom(*args, &block)
      Leaf::Custom.new(*args, &block)
    end

    def horizontal(char)
      raise(ArgumentError.new("Must pass single character")) if char.length != 1
      custom(height: 1) { |w, h| char * w }
    end

    def vertical(char)
      raise(ArgumentError.new("Must pass single character")) if char.length != 1
      custom(width: 1) { |w, h| ([char] * h).join("\n") }
    end

    def bordered(chars, *args, &block)
      rows(
        cols(
          literal(chars[:tl]),
          horizontal(chars[:t]),
          literal(chars[:tr]),
        ),
        cols(
          vertical(chars[:l]),
          custom(*args, &block),
          vertical(chars[:r]),
        ),
        cols(
          literal(chars[:bl]),
          horizontal(chars[:b]),
          literal(chars[:br]),
        )
      )
    end

  end
end
