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
    assert_raises(ArgumentError) { Leaf::Spacer.new(-1) }
    assert_raises(ArgumentError) { Leaf::Spacer.new("hello") }
  end

  def test_layout_with_spacers
    res = Layouter.rows(
      Layouter.cols(
        Layouter.spacer(2),
        Layouter.spacer(1),
      ),
      Layouter.cols(
        Layouter.spacer(1),
        Layouter.spacer(2),
      ),
    )
    res.layout(120, 30)
    assert_equal 120, res.calculated_width
    assert_equal 30, res.calculated_height
    assert_equal 120, res[0].calculated_width
    assert_equal 15, res[0].calculated_height
    assert_equal 120, res[1].calculated_width
    assert_equal 15, res[1].calculated_height
    assert_equal 80, res[0][0].calculated_width
    assert_equal 15, res[0][0].calculated_height
    assert_equal 40, res[0][1].calculated_width
    assert_equal 15, res[0][1].calculated_height
    assert_equal 40, res[1][0].calculated_width
    assert_equal 15, res[1][0].calculated_height
    assert_equal 80, res[1][1].calculated_width
    assert_equal 15, res[1][1].calculated_height
  end

end
