require 'dohtest/failure'

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

  # expected arguments:
  # one or more exception classes (or modules); a class matches only exactly, not a subclass
  # then optionally a regex the exception's message must match
  # then optionally a failure message to display if the assertion fails
  def assert_raises(*expected)
    msg = expected.pop if expected.last.is_a?(String)
    message_regex = expected.pop if expected.last.is_a?(Regexp)
    if expected.empty? || !expected.all? { |elem| elem.is_a?(Module) }
      raise ArgumentError, "assert_raises takes exception classes, then an optional regex, then an optional failure message; got: #{expected.inspect}"
    end
    failure_expected = {:classes => expected, :message_regex => message_regex}
    begin
      yield
      no_exception = true
    rescue Exception => actual_excpt
      actual_class = actual_excpt.class
      class_matched = expected.any? { |elem| elem.instance_of?(Module) ? actual_excpt.kind_of?(elem) : elem == actual_class }
      if class_matched && (message_regex.nil? || actual_excpt.message.match?(message_regex))
        @runner.assertion_passed
      else
        raise DohTest::Failure.new(msg, :raises, failure_expected, actual_excpt)
      end
    end
    raise DohTest::Failure.new(msg, :raises, failure_expected, nil) if no_exception
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
