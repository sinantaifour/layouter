module Layouter
  class Element

    attr_reader :calculated_width, :calculated_height

    [
      :min_width, :max_width, :min_height, :max_height,
       :importance, :layout
    ].each do |m|
      define_method(m) do
        raise(NotImplementedError, "Implemented by subclasses")
      end
    end

    def layout?
      !!@calculated_width && !!@calculated_height
    end

    private

    def layout!
      raise(GenericError.new("Must layout first")) unless layout?
    end

  end
end
