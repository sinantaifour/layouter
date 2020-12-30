module Layouter

  class GenericError < StandardError
  end

  class LayoutError < GenericError

    attr_reader :dimension, :reason

    def initialize(dimension, reason)
      @dimension, @reason = dimension, reason
      msg = "#{dimension.to_s.capitalize} is #{reason.to_s.gsub("_", " ")}"
      super(msg)
    end

  end

end
