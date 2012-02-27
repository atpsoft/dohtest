require 'doh/test/backtrace_parser'
require 'set'

module DohTest

class StreamOutput
  def initialize
    @error_count = @groups_ran = @groups_skipped = @tests_ran = @tests_skipped = @assertions_failed = @assertions_passed = 0
    @badness = Set.new
  end

  def run_begin(config)
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

    if @groups_skipped == 0
      groups_str = "#@groups_ran groups"
    else
      total_groups = @groups_ran + @groups_skipped
      groups_str = "#{total_groups} groups: #@groups_ran ran, #@groups_skipped skipped"
    end

    if @tests_skipped == 0
      tests_str = "#@tests_ran tests"
    else
      total_tests = @tests_ran + @tests_skipped
      tests_str = "#{total_tests} tests: #@tests_ran ran, #@tests_skipped skipped"
    end

    if @assertions_failed == 0
      assertions_str = "all #{total_assertions} assertions passed"
    else
      assertions_str = "#{total_assertions} assertions: #@assertions_passed passed, #@assertions_failed failed"
    end
    puts "#@error_count errors; #{groups_str}; #{tests_str}; #{assertions_str}"

    # this is to generate an exit code; true translates to 0, false to 1
    @error_count == 0 && @assertions_failed == 0
  end

  def group_begin(group_name)
  end

  def group_end(group_name, tests_ran, tests_skipped, assertions_passed, assertions_failed)
    @tests_skipped += tests_skipped
    if tests_ran == 0
      @groups_skipped += 1
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
    parser = DohTest::BacktraceParser.new(excpt.backtrace)
    warn "#{title} in #{group_name}.#{test_name}"
    badname = if display_name then "#{excpt.class}: " else '' end
    warn "=> #{badname}#{excpt}"
    # main_call = parser.relevant_stack.last
    # warn "=> #{main_call.first}:#{main_call.last}"
    # warn "=> #{parser.summary}"
    parser.relevant_stack.each do |path, line|
      warn "=> #{path}:#{line}"
    end
  end
end

end
