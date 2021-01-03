require 'minitest/autorun'
require 'layouter'

class TestLayouter < Minitest::Test

  include Layouter

  def test_distribute
    assert_equal [], Parent.distribute(0, [], [])
    assert_equal [10], Parent.distribute(10, [1], [100])
    assert_equal [10], Parent.distribute(10, [1], [Float::INFINITY])
    assert_equal [33, 67], Parent.distribute(100, [1, 2], [100, 100])
    assert_equal [33, 67], Parent.distribute(100, [1, 2], [33, 100])
    assert_equal [32, 68], Parent.distribute(100, [1, 2], [32, 100])
    assert_equal [100, 100], Parent.distribute(200, [1, 2], [100, 100])
    assert_equal [67, 133], Parent.distribute(200, [1, 2], [100, 200])
    assert_equal [66, 67, 67], Parent.distribute(200, [1, 1, 1], [100] * 3)
    assert_equal [66, 67, 67], Parent.distribute(200, [1, 1, 1.001], [100] * 3)
    assert_equal [67, 66, 67], Parent.distribute(200, [1.001, 1, 1], [100] * 3)
    assert_equal [33, 33, 34], Parent.distribute(100, [1, 1, 1], [50] * 3)
    assert_equal [33, 34, 33], Parent.distribute(100, [1, 1, 0.999], [50] * 3)
    assert_equal [66, 67, 67], Parent.distribute(200, [1, 1, 1], [66, 70, 70])
  end

  def test_distribute_assertions
    assert_raises(AssertionError) { Parent.distribute(1.0, [], []) }
    assert_raises(AssertionError) { Parent.distribute(1, [1], [1, 2]) }
    assert_raises(AssertionError) { Parent.distribute(1, [1], [1.0]) }
    assert_raises(AssertionError) { Parent.distribute(2, [1], [1]) }
  end

  def test_parent_invalid_arguments
    assert_raises(ArgumentError) { Parent.new(:stuff, []) }
    assert_raises(ArgumentError) { Parent.new(:rows, [1, 2]) }
    assert_raises(ArgumentError) { Parent.new(:rows, [Leaf::Spacer.new, 2]) }
  end

  def test_spacer_invalid_arguments
    assert_raises(ArgumentError) { Leaf::Spacer.new(weight: "hello") }
    assert_raises(ArgumentError) { Leaf::Spacer.new(weight: -1) }
  end

  def test_annotation_invalid_arguments
    assert_raises(ArgumentError) { Leaf::Annotation.new([]) }
    assert_raises(ArgumentError) { Leaf::Annotation.new(:symbol) }
  end

  def test_render_without_layout
    root = Layouter.rows(Layouter.spacer)
    assert_equal false, root.layout?
    assert_raises(StateError) { root.render }
  end

  def test_layout_width_too_small
    root = Layouter.cols(Layouter.literal("Hello, world!"))
    err = assert_raises(LayoutError) { root.layout(5, 1) }
    assert_equal :width, err.dimension
    assert_equal :too_small, err.reason
  end

  def test_layout_width_too_big
    root = Layouter.cols(Layouter.literal("Hello, world!"))
    err = assert_raises(LayoutError) { root.layout(100, 1) }
    assert_equal :width, err.dimension
    assert_equal :too_big, err.reason
  end

  def test_layout_height_too_small
    root = Layouter.rows(
      Layouter.literal("Hello, world!"),
      Layouter.literal("Hello, world!"),
    )
    err = assert_raises(LayoutError) { root.layout("Hello, world!".length, 1) }
    assert_equal :height, err.dimension
    assert_equal :too_small, err.reason
  end

  def test_layout_height_too_big
    root = Layouter.rows(Layouter.literal("Hello, world!"))
    err = assert_raises(LayoutError) { root.layout("Hello, world!".length, 2) }
    assert_equal :height, err.dimension
    assert_equal :too_big, err.reason
  end

  def test_layout_with_spacers
    root = Layouter.rows(
      Layouter.cols(
        Layouter.spacer(weight: 2),
        Layouter.spacer,
      ),
      Layouter.cols(
        Layouter.spacer,
        Layouter.spacer(weight: 2),
      ),
    )
    root.layout(120, 30)
    assert_equal 120, root.calculated_width
    assert_equal 30, root.calculated_height
    [0, 1].each do |i|
      assert_equal 120, root[i].calculated_width
      assert_equal 15, root[i].calculated_height
      [0, 1].each do |j|
        assert_equal 15, root[i][j].calculated_height
      end
    end
    assert_equal 80, root[0][0].calculated_width
    assert_equal 40, root[0][1].calculated_width
    assert_equal 40, root[1][0].calculated_width
    assert_equal 80, root[1][1].calculated_width
    assert_equal ([" " * 120] * 30).join("\n"), root.render
  end

  def test_layout_with_literals
    root = Layouter.rows(
      Layouter.spacer,
      Layouter.cols(
        Layouter.spacer,
        Layouter.literal(Math::PI),
        Layouter.spacer,
        Layouter.literal("Hello, world!"),
        Layouter.spacer,
      ),
      Layouter.spacer,
    )
    root.layout(50, 3)
    ref = [
      "                                                  ",
      "      3.141592653589793       Hello, world!       ",
      "                                                  ",
    ].join("\n")
    assert_equal ref, root.render
  end

  def test_layout_with_trimmed_annotations
    root = Layouter.rows(
      Layouter.annotation("Hello, world!"),
      Layouter.annotation(Math::PI),
    )
    root.layout(7, 2)
    assert_equal "Hello,\u2026\n~3.1415", root.render
  end

end
