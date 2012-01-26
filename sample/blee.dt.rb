require_relative 'helper'

class TestBlee < DohTest::TestGroup
  include BlahHelper

  def verify_diff(sum, value1, value2)
    assert_equal(sum, value1 - value2)
  end

  def test_more_goodness
    verify_sum(4, 2, 2)
    verify_sum(5, 2, 3)
    verify_sum(8, 5, 3)
    verify_sum(15, 9, 6)
  end

  def test_partial_success
    verify_diff(2, 4, 2)
    verify_diff(2, 5, 3)
    verify_diff(2, 4, 3)
  end

  def test_yet_more_goodness
    verify_sum(4, 2, 2)
  end

  def test_silly_error
    verify_diff(2, 4, 2)
    badness = 5 / 0
  end

  def test_lots_more_goodness
    verify_sum(4, 2, 2)
  end

  def test_lots_more_goodness2
    verify_sum(4, 2, 2)
  end

  def test_lots_more_goodness3
    verify_sum(4, 2, 2)
  end

  def test_other_stuff
    verify_sum(4, 2, 2)
    verify_sum(5, 1, 3)
  end

  def test_lots_more_goodness4
    verify_sum(4, 2, 2)
  end

end


