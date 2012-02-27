require 'doh/test/backtrace_parser'

# this class provides an example of how you could replace the built-in doh/test/stream_output class
# you could use the class below in the dohtest binary instead

module DohTest

class SimpleOutput
  def run_begin(config)
    puts "run begin: #{config}"
  end

  def run_end(duration)
    puts "run end: #{duration}"
  end

  def group_begin(group_name)
    puts "group begin: #{group_name}"
  end

  def group_end(group_name, tests_ran, tests_skipped, assertions_passed, assertions_failed)
    puts "group end: #{group_name}; #{tests_ran} tests ran, #{tests_skipped} tests skipped, assertions passed #{assertions_passed}, assertions failed #{assertions_failed}"
  end

  def test_begin(group_name, test_name)
    puts "test begin: #{group_name}.#{test_name}"
  end

  def test_end(group_name, test_name)
    puts "test end: #{group_name}.#{test_name}"
  end

  def test_error(group_name, test_name, error)
    warn "test error: #{group_name}.#{test_name} => #{error.class} at #{DohTest::backtrace_summary(error)} => #{error}"
  end

  def assertion_failed(group_name, test_name, failure)
    warn "assertion failed: #{group_name}.#{test_name} at #{DohTest::backtrace_summary(failure)} => #{failure}"
  end

  def assertion_passed(group_name, test_name)
    puts "assertion passed: #{group_name}.#{test_name}"
  end
end

end
