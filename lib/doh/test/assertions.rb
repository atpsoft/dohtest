require 'doh/test/failure'

module DohTest

class TestGroup
  def assert(boolean, msg = nil)
    if boolean
      @runner.assertion_passed
    else
      raise DohTest::Failure.new(msg, :boolean, nil, nil)
    end
  end

  def assert_equal(expected, actual, msg = nil)
    if expected == actual
      @runner.assertion_passed
    else
      raise DohTest::Failure.new(msg, :equal, expected, actual)
    end
  end

  def assert_raises(*args)
    msg = args.pop if args.last.is_a?(String)
    begin
      yield
      no_exception = true
    rescue Exception => excpt
      actual = excpt.class
      if args.include?(actual)
        @runner.assertion_passed
      else
        raise DohTest::Failure.new(msg, :raises, expected, actual)
      end
    end
    raise DohTest::Failure.new(msg, :raises, expected, nil) if no_exception
  end

  def assert_instance_of(expected_class, actual_object, msg = nil)
    if actual_object.instance_of?(expected_class)
      @runner.assertion_passed
    else
      raise DohTest::Failure.new(msg, :instance_of, expected_class, actual_object)
    end
  end

  def assert_match(expected_regex, actual_str, msg = nil)
    if actual_str.match(expected_regex)
      @runner.assertion_passed
    else
      raise DohTest::Failure.new(msg, :match, expected_regex, actual_str)
    end
  end

  def assert_not_equal(expected, actual, msg = nil)
    if expected != actual
      @runner.assertion_passed
    else
      raise DohTest::Failure.new(msg, :not_equal, expected, actual)
    end
  end
end

end
