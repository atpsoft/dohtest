require_relative 'helper'

class TestBlah < DohTest::TestGroup
  include BlahHelper

  def verify_diff(sum, value1, value2)
    assert_equal(sum, value1 - value2)
  end

  def test_some_sums
    verify_sum(4, 2, 2)
    verify_sum(5, 1, 3)
  end

  def test_other
    verify_sum(4, 2, 2)
    verify_sum(5, 1, 3)
  end

  def test_lots_more_goodness1
    verify_sum(4, 2, 2)
  end

  def test_lots_more_goodness2
    verify_sum(4, 2, 2)
  end

  def test_lots_more_goodness3
    verify_sum(4, 2, 2)
  end

  def test_all_success
    verify_sum(4, 2, 2)
    verify_sum(5, 2, 3)
    verify_sum(8, 5, 3)
    verify_sum(15, 9, 6)
  end

  def test_getting_an_error
    verify_diff(2, 4, 2)
    verify_diff(2, nil, 2)
  end

  def test_afew_diffs
    verify_diff(2, 4, 2)
    verify_diff(2, 5, 3)
    verify_diff(2, 4, 3)
  end
end


