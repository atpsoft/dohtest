require 'doh/test/backtrace_parser'
require 'set'

module DohTest

class StreamOutput
  def initialize
    @error_count = @group_cnt = @tests_ran = @tests_skipped = @assertions_failed = @assertions_passed = 0
    @badness = Set.new
  end

  def run_begin(config)
    puts "running tests with config: #{config}"
  end

  def run_end
    total_assertions = @assertions_passed + @assertions_failed
    puts "\n\n#@error_count errors, #@group_cnt groups, #@tests_ran tests, #{@tests_skipped} skipped, #{total_assertions} assertions, #@assertions_passed passed, #@assertions_failed failed"
    puts "completed in 0.043702s, 22.8822 tests/s, 45.7645 assertions/s <TODO: put real values here>"
    # this is to generate an exit code; true translates to 0, false to 1
    @error_count == 0 && @assertions_failed == 0
  end

  def group_begin(group_name)
    @group_cnt += 1
  end

  def group_end(group_name)
    puts "success in #{group_name}" unless @badness.include?(group_name)
  end

  def tests_skipped(group_name, count)
    @tests_skipped += count
  end

  def test_begin(group_name, test_name)
  end

  def test_end(group_name, test_name)
    @tests_ran += 1
  end

  def test_error(group_name, test_name, error)
    @badness.add(group_name)
    @error_count += 1
    display_badness('error', group_name, test_name, error, true)
  end

  def assertion_failed(group_name, test_name, failure)
    @badness.add(group_name)
    @assertions_failed += 1
    display_badness('failure', group_name, test_name, failure, false)
  end

  def assertion_passed(group_name, test_name)
    @assertions_passed += 1
  end

private
  def display_badness(title, group_name, test_name, excpt, display_name)
    warn "#{title} in #{group_name}.#{test_name} at #{DohTest::backtrace_summary(excpt)}"
    badname = if display_name then "#{excpt.class}: " else '' end
    warn "=> #{badname}#{excpt}"
  end
end

end
