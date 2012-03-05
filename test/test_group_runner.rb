require 'doh/root'; Doh::find_root_from_file
require 'minitest/autorun'
require 'doh/test/group_runner'
require 'doh/test/capture_output'

module DohTest

class TestGroupRunner < MiniTest::Unit::TestCase
  def verify_event(expected_pairs, event)
    expected_pairs.each_pair do |key, value|
      assert_equal(value, event[key])
    end
  end

  def run_group(group_klass, grepstr = nil)
    @group_klass = group_klass
    @output = CaptureOutput.new
    config = if grepstr then {:grep => grepstr} else nil end
    @runner = GroupRunner.new(@group_klass, @output, config)
    @runner.run
    @events = @output.events
    assert_equal({:name => 'group_begin', :group_name => @group_klass.to_s}, @events.shift)
    verify_event({:name => 'group_end', :group_name => @group_klass.to_s}, @events.last)
  end


  class EmptyTestGroup < DohTest::TestGroup; end
  def test_empty_group
    run_group(EmptyTestGroup)
    assert_equal(1, @events.size)
    assert_equal({:name => 'group_end', :group_name => EmptyTestGroup.to_s, :tests_ran => 0, :tests_skipped => 0, :assertions_passed => 0, :assertions_failed => 0}, @events.shift)
  end

  class SetupTeardownWithErrorGroup < DohTest::TestGroup
    def initialize
      @@ran_setup = @@ran_teardown = false
    end

    def setup
      @@ran_setup = true
    end

    def teardown
      @@ran_teardown = true
    end

    def test_just_an_error
      raise "an error"
    end
  end

  def test_setup_teardown_with_error
    run_group(SetupTeardownWithErrorGroup)
    assert_equal(4, @events.size)
    assert_equal('test_begin', @events.shift[:name])
    assert_equal('test_error', @events.shift[:name])
    assert_equal('test_end', @events.shift[:name])
    verify_event({:tests_ran => 1, :tests_skipped => 0, :assertions_passed => 0, :assertions_failed => 0}, @events.shift)
    assert(@group_klass.class_variable_get(:@@ran_setup))
    assert(@group_klass.class_variable_get(:@@ran_teardown))
  end

  class BeforeAfterWithErrorGroup < DohTest::TestGroup
    def initialize
      @@ran_before = @@ran_after = false
    end

    def before_each
      @@ran_before = true
    end

    def after_each
      @@ran_after = true
    end

    def test_just_an_error
      raise "an error"
    end
  end

  def test_before_after_with_error
    run_group(BeforeAfterWithErrorGroup)
    assert_equal(4, @events.size)
    assert_equal('test_begin', @events.shift[:name])
    assert_equal('test_error', @events.shift[:name])
    assert_equal('test_end', @events.shift[:name])
    verify_event({:tests_ran => 1, :tests_skipped => 0, :assertions_passed => 0, :assertions_failed => 0}, @events.shift)
    assert(@group_klass.class_variable_get(:@@ran_before))
    assert(@group_klass.class_variable_get(:@@ran_after))
  end

  class ErrorInBefore < DohTest::TestGroup
    def initialize
      @@ran_before = @@ran_test = @@ran_after = false
    end

    def before_each
      @@ran_before = true
      raise "blah"
    end

    def after_each
      @@ran_after = true
    end

    def test_no_error
      @@ran_test = true
    end
  end

  def test_error_in_before
    run_group(ErrorInBefore)
    assert_equal(4, @events.size)
    assert_equal('test_begin', @events.shift[:name])
    assert_equal('test_error', @events.shift[:name])
    assert_equal('test_end', @events.shift[:name])
    verify_event({:tests_ran => 1, :tests_skipped => 0, :assertions_passed => 0, :assertions_failed => 0}, @events.shift)
    assert(@group_klass.class_variable_get(:@@ran_before))
    assert(!@group_klass.class_variable_get(:@@ran_test))
    assert(@group_klass.class_variable_get(:@@ran_after))
  end

  class GreppingWithPass < DohTest::TestGroup
    def test_blah
      assert(true)
    end
    def test_blee
      assert(true);assert(true)
    end
    def test_blahblah
      assert(true);assert(true);assert(true)
    end
    def test_blahblee
      assert(true);assert(true);assert(true);assert(true)
    end
    def test_blahbloo
      assert(true);assert(true);assert(true);assert(true);assert(true)
    end
  end

  def test_grepping_with_pass_no_grep
    run_group(GreppingWithPass)
    # group_end (1) + test_begin (5) + test_end (5) + assertion_passed (15)
    assert_equal(26, @events.size)
    verify_event({:tests_ran => 5, :tests_skipped => 0, :assertions_passed => 15, :assertions_failed => 0}, @events.last)
  end

  def test_grepping_with_pass_grep_blah
    run_group(GreppingWithPass, 'blah')
    verify_event({:tests_ran => 4, :tests_skipped => 1, :assertions_passed => 13, :assertions_failed => 0}, @events.last)
  end

  def test_grepping_with_pass_grep_blee
    run_group(GreppingWithPass, 'blee')
    verify_event({:tests_ran => 2, :tests_skipped => 3, :assertions_passed => 6, :assertions_failed => 0}, @events.last)
  end

  def test_grepping_with_pass_grep_bloo
    run_group(GreppingWithPass, 'bloo')
    verify_event({:tests_ran => 1, :tests_skipped => 4, :assertions_passed => 5, :assertions_failed => 0}, @events.last)
  end

  def test_grepping_with_pass_grep_zzz
    run_group(GreppingWithPass, 'zzz')
    verify_event({:tests_ran => 0, :tests_skipped => 5, :assertions_passed => 0, :assertions_failed => 0}, @events.last)
  end
end

end
