module DohTest

AssertionFailed = Class.new(StandardError)

class TestGroup
  def assert(condition, msg = nil)
    if condition
      @runner.assertion_passed
    else
      raise DohTest::AssertionFailed, msg || "Assertion failed."
    end
  end

  def build_equal_msg(expected, actual)
    if (expected.to_s.size + actual.to_s.size) < 50
      "expected: #{expected}; actual: #{actual}"
    else
      "\nexpected: #{expected}\n  actual: #{actual}"
    end
  end

  def assert_equal(expected, actual, msg = nil)
    assert(expected == actual, msg || build_equal_msg(expected, actual))
  end

  def assert_raises(*args)
    msg = args.pop if args.last.is_a?(String)

    begin
      yield
      no_exception = true
    rescue Exception => excpt
      assert(args.include?(excpt.class), msg || "expected: #{args}; actual: #{excpt}")
      return
    end

    if no_exception
      raise DohTest::AssertionFailed, msg || "expected: #{args}, but no exception was raised"
    end
  end

  def assert_instance_of(expected_class, actual_object, msg = nil)
    assert(actual_object.instance_of?(expected_class), msg || "expected class: #{expected_class}; actual: #{actual_object.class}")
  end

  def assert_match(expected_regex, actual_str, msg = nil)
    assert(actual_str.match(expected_regex), msg || "expected regex #{expected_regex} to match str: #{actual_str}")
  end

  def assert_not_equal(expected, actual, msg = nil)
    assert(expected != actual, msg || "expected unequal values")
  end
end

end
