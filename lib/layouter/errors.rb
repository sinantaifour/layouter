module Layouter

  # Root error, never raised.
  class GenericError < StandardError; end

  # Raised if the state of an object is inconsistent with the called method.
  class StateError < GenericError; end

  # Should never be raised, unless our code is buggy.
  class AssertionError < GenericError; end

  # Only raised while laying out, if it is not possible to layout.
  class LayoutError < GenericError

    attr_reader :dimension, :reason

    def initialize(dimension, reason)
      @dimension, @reason = dimension, reason
      msg = "#{dimension.to_s.capitalize} is #{reason.to_s.gsub("_", " ")}"
      super(msg)
    end

  end

end
