module BlahHelper
  def verify_sum(sum, value1, value2)
    assert_equal(sum, value1 + value2)
  end
end
