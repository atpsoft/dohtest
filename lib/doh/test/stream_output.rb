require 'doh/test/backtrace_parser'
require 'set'
require 'term/ansicolor'

module DohTest

class StreamOutput
  DEFAULT_COLORS = {:failure => :red, :error => :magenta, :info => :blue, :success => :green}.freeze

  def initialize
    @error_count = @groups_ran = @groups_skipped = @tests_ran = @tests_skipped = @assertions_failed = @assertions_passed = 0
    @callback_succeeded = true
    @badness = Set.new
  end

  def run_begin(config)
    @config = config
    puts "running tests with config: #{config}"
  end

  def run_end(duration)
    total_assertions = @assertions_passed + @assertions_failed

    if duration >= 1
      tests_per_second = (@tests_ran / duration).round(2)
      assertions_per_second = (total_assertions / duration).round(2)
      puts "\n\ncompleted in #{duration.round(2)}s, #{tests_per_second} tests/s, #{assertions_per_second} assertions/s"
    else
      puts "\n\ncompleted in #{duration.round(2)}s"
    end

    if @error_count == 0
      error_str = "0 errors"
    else
      error_str = colorize(:error, "#@error_count errors")
    end

    if @groups_skipped == 0
      group_str = "#@groups_ran groups"
    else
      total_groups = @groups_ran + @groups_skipped
      group_str = "#{total_groups} groups: #@groups_ran ran, #@groups_skipped skipped"
    end

    if @tests_skipped == 0
      test_str = "#@tests_ran tests"
    else
      total_tests = @tests_ran + @tests_skipped
      test_str = "#{total_tests} tests: #@tests_ran ran, #@tests_skipped skipped"
    end

    if total_assertions == 0
      assertion_str = colorize(:info, "no assertions run")
    elsif @assertions_failed == 0
      assertion_str = "all #{total_assertions} assertions passed"
    else
      failed_str = colorize(:failure, "#@assertions_failed failed")
      assertion_str = "#{total_assertions} assertions: #@assertions_passed passed, #{failed_str}"
    end

    success = (total_assertions > 0) && (@error_count == 0) && (@assertions_failed == 0) && @callback_succeeded

    msg = "#{error_str}; #{group_str}; #{test_str}; #{assertion_str}"
    msg = colorize(:success, msg) if success
    puts msg

    # this is to generate an exit code; true translates to 0, false to 1
    success
  end

  def group_begin(group_name)
  end

  def group_end(group_name, tests_ran, tests_skipped, assertions_passed, assertions_failed)
    @tests_skipped += tests_skipped
    if tests_ran == 0
      if tests_skipped > 0
        @groups_skipped += 1
      else
        puts colorize(:info, "no tests defined in #{group_name}")
      end
      return
    end
    @groups_ran += 1
    total_tests = tests_ran + tests_skipped
    total_assertions = assertions_passed + assertions_failed
    skipped_str = if tests_skipped > 0 then ": #{tests_ran} ran, #{tests_skipped} skipped" else '' end
    puts "success in #{group_name}: #{total_tests} tests#{skipped_str}; #{total_assertions} assertions" unless @badness.include?(group_name)
  end

  def test_begin(group_name, test_name)
  end

  def test_end(group_name, test_name)
    @tests_ran += 1
  end

  def test_error(group_name, test_name, error)
    @badness.add(group_name)
    @error_count += 1
    display_badness(group_name, test_name, error)
  end

  def assertion_failed(group_name, test_name, failure)
    @badness.add(group_name)
    @assertions_failed += 1
    display_badness(group_name, test_name, failure)
  end

  def callback_failed(test_name)
    @callback_succeeded = false
    warn colorize(:error, "callback #{test_name} failed")
  end

  def assertion_passed(group_name, test_name)
    @assertions_passed += 1
  end

private
  def colorize(type, msg)
    return msg if @config[:no_color]
    color = @config["#{type}_color".to_sym] || DEFAULT_COLORS[type]
    "#{Term::ANSIColor.send(color)}#{Term::ANSIColor.bold}#{msg}#{Term::ANSIColor.clear}"
  end

  def display_badness(group_name, test_name, excpt)
    badness_type = if excpt.is_a?(DohTest::Failure) then :failure else :error end
    parser = DohTest::BacktraceParser.new(excpt.backtrace)
    warn colorize(badness_type, "#{badness_type} in #{group_name}.#{test_name} at:")
    parser.relevant_stack.each do |path, line|
      warn "#{path}:#{line}"
    end
    if badness_type == :error
      warn colorize(:info, "#{excpt.class}: #{excpt.message}")
    else
      display_failure_message(excpt)
    end
  end

  def display_failure_message(failure)
    if failure.message.empty?
      send("display_#{failure.assert}_failure", failure)
    else
      warn colorize(:info, failure.message)
    end
  end

  def display_boolean_failure(failure)
    warn colorize(:info, "assertion failed")
  end

  def display_equal_failure(failure)
    warn colorize(:info, "expected: #{failure.expected.inspect}\n  actual: #{failure.actual.inspect}")
  end

  def display_raises_failure(failure)
    if failure.actual
      expected_str = if (failure.expected.size == 1) then failure.expected.first else "one of #{failure.expected.join(',')}" end
      warn colorize(:info, "expected: #{expected_str}; actual: #{failure.actual.class}: #{failure.actual.message}")
      DohTest::BacktraceParser.new(failure.actual.backtrace).relevant_stack.each do |path, line|
        warn "#{path}:#{line}"
      end
    else
      warn colorize(:info, "expected: #{failure.expected}, but no exception was raised")
    end
  end

  def display_instance_of_failure(failure)
    warn colorize(:info, "expected class: #{failure.expected}; actual class: #{failure.actual.class}, object: #{failure.actual}")
  end

  def display_match_failure(failure)
    warn colorize(:info, "expected regex #{failure.expected} to match str: #{failure.actual}")
  end

  def display_not_equal_failure(failure)
    warn colorize(:info, "expected unequal values; both are: #{failure.expected.inspect}")
  end

end

end
