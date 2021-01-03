require 'minitest/autorun'
require 'layouter'

class TestLayouter < Minitest::Test

  include Layouter

  def test_parent_invalid_arguments
    assert_raises(ArgumentError) { Parent.new(:stuff, []) }
    assert_raises(ArgumentError) { Parent.new(:rows, [1, 2]) }
    assert_raises(ArgumentError) { Parent.new(:rows, [Leaf::Spacer.new, 2]) }
  end

  def test_spacer_invalid_arguments
    assert_raises(ArgumentError) { Leaf::Spacer.new(weight: "hello") }
    assert_raises(ArgumentError) { Leaf::Spacer.new(weight: -1) }
  end

  def test_render_without_layout
    root = Layouter.rows(Layouter.spacer)
    assert_raises(GenericError) { root.render }
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
    assert_equal [" " * 120] * 30, root.render
  end

end
