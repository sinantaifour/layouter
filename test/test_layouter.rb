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
        Layouter.spacer,
        Layouter.spacer,
      ),
      Layouter.cols(
        Layouter.spacer,
        Layouter.spacer,
      ),
    )
    res.layout(120, 30)
    assert_equal 120, res.calculated_width
    assert_equal 30, res.calculated_height
    [0, 1].each do |i|
      assert_equal 120, res[i].calculated_width
      assert_equal 15, res[i].calculated_height
      [0, 1].each do |j|
        assert_equal 60, res[i][j].calculated_width
        assert_equal 15, res[i][j].calculated_height
      end
    end
    assert_equal [" " * 120] * 30, res.render
  end

end
