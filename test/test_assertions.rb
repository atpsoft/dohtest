require 'dohroot'; Doh.find_root_from_file
require 'minitest/autorun'
require 'dohtest/group_runner'
require 'dohtest/capture_output'
require File.join(Doh.root, 'test/support/group_runner_helper')

module DohTest

class TestAssertions < Minitest::Test
  include GroupRunnerHelper

  def verify_passed(group_klass)
    run_group(group_klass)
    assert_equal(4, @events.size)
    assert_equal('test_begin', @events.shift[:name])
    assert_equal('assertion_passed', @events.shift[:name])
    assert_equal('test_end', @events.shift[:name])
    verify_event({:tests_ran => 1, :tests_skipped => 0, :assertions_passed => 1, :assertions_failed => 0}, @events.shift)
  end

  def run_failed_group(group_klass)
    run_group(group_klass)
    assert_equal(4, @events.size)
    assert_equal('test_begin', @events.shift[:name])
    event = @events.shift
    assert_equal('assertion_failed', event[:name])
    assert_equal('test_end', @events.shift[:name])
    verify_event({:tests_ran => 1, :tests_skipped => 0, :assertions_passed => 0, :assertions_failed => 1}, @events.shift)
    assert_equal(:raises, event[:failure].assert)
    return event[:failure]
  end

  def verify_argument_error(group_klass)
    run_group(group_klass)
    assert_equal(4, @events.size)
    assert_equal('test_begin', @events.shift[:name])
    event = @events.shift
    assert_equal('test_error', event[:name])
    assert_equal(ArgumentError, event[:error].class)
    assert_equal('test_end', @events.shift[:name])
    verify_event({:tests_ran => 1, :tests_skipped => 0, :assertions_passed => 0, :assertions_failed => 0}, @events.shift)
  end

  class RaisesClass < DohTest::TestGroup
    def test_raises
      assert_raises(ArgumentError) { raise ArgumentError }
    end
  end

  def test_raises_class
    verify_passed(RaisesClass)
  end

  class RaisesOneOfSeveralClasses < DohTest::TestGroup
    def test_raises
      assert_raises(TypeError, ArgumentError) { raise ArgumentError }
    end
  end

  def test_raises_one_of_several_classes
    verify_passed(RaisesOneOfSeveralClasses)
  end

  module TaggedError; end
  class TaggedRuntimeError < RuntimeError
    include TaggedError
  end

  class RaisesModule < DohTest::TestGroup
    def test_raises
      assert_raises(TaggedError) { raise TaggedRuntimeError }
    end
  end

  def test_raises_module
    verify_passed(RaisesModule)
  end

  class RaisesWrongClass < DohTest::TestGroup
    def test_raises
      assert_raises(TypeError) { raise ArgumentError }
    end
  end

  def test_raises_wrong_class
    failure = run_failed_group(RaisesWrongClass)
    assert_equal(ArgumentError, failure.actual.class)
  end

  class RaisesNothing < DohTest::TestGroup
    def test_raises
      assert_raises(ArgumentError) { nil }
    end
  end

  def test_raises_nothing
    failure = run_failed_group(RaisesNothing)
    assert_nil(failure.actual)
  end

  class RaisesMatchingMessage < DohTest::TestGroup
    def test_raises
      assert_raises(ArgumentError, /abc/) { raise ArgumentError, 'xx abc xx' }
    end
  end

  def test_raises_matching_message
    verify_passed(RaisesMatchingMessage)
  end

  class RaisesNonMatchingMessage < DohTest::TestGroup
    def test_raises
      assert_raises(ArgumentError, /abc/) { raise ArgumentError, 'xyz' }
    end
  end

  def test_raises_non_matching_message
    failure = run_failed_group(RaisesNonMatchingMessage)
    assert_equal('xyz', failure.actual.message)
    assert_equal({:classes => [ArgumentError], :message_regex => /abc/}, failure.expected)
  end

  class RaisesMatchingMessageWrongClass < DohTest::TestGroup
    def test_raises
      assert_raises(TypeError, /abc/) { raise ArgumentError, 'abc' }
    end
  end

  def test_raises_matching_message_wrong_class
    failure = run_failed_group(RaisesMatchingMessageWrongClass)
    assert_equal(ArgumentError, failure.actual.class)
  end

  class RaisesNothingWithRegex < DohTest::TestGroup
    def test_raises
      assert_raises(ArgumentError, /abc/) { nil }
    end
  end

  def test_raises_nothing_with_regex
    failure = run_failed_group(RaisesNothingWithRegex)
    assert_nil(failure.actual)
  end

  class RaisesWithFailureMessage < DohTest::TestGroup
    def test_raises
      assert_raises(TypeError, 'custom message') { raise ArgumentError }
    end
  end

  def test_raises_with_failure_message
    failure = run_failed_group(RaisesWithFailureMessage)
    assert_equal('custom message', failure.message)
  end

  class RaisesWithRegexAndFailureMessage < DohTest::TestGroup
    def test_raises
      assert_raises(ArgumentError, /abc/, 'custom message') { raise ArgumentError, 'xyz' }
    end
  end

  def test_raises_with_regex_and_failure_message
    failure = run_failed_group(RaisesWithRegexAndFailureMessage)
    assert_equal('custom message', failure.message)
  end

  class RaisesNoArguments < DohTest::TestGroup
    def test_raises
      assert_raises { nil }
    end
  end

  def test_raises_no_arguments
    verify_argument_error(RaisesNoArguments)
  end

  class RaisesOnlyRegex < DohTest::TestGroup
    def test_raises
      assert_raises(/abc/) { nil }
    end
  end

  def test_raises_only_regex
    verify_argument_error(RaisesOnlyRegex)
  end

  class RaisesOnlyFailureMessage < DohTest::TestGroup
    def test_raises
      assert_raises('custom message') { nil }
    end
  end

  def test_raises_only_failure_message
    verify_argument_error(RaisesOnlyFailureMessage)
  end

  class RaisesRegexBeforeClass < DohTest::TestGroup
    def test_raises
      assert_raises(/abc/, ArgumentError) { nil }
    end
  end

  def test_raises_regex_before_class
    verify_argument_error(RaisesRegexBeforeClass)
  end

  class RaisesRegexAfterFailureMessage < DohTest::TestGroup
    def test_raises
      assert_raises(ArgumentError, 'custom message', /abc/) { nil }
    end
  end

  def test_raises_regex_after_failure_message
    verify_argument_error(RaisesRegexAfterFailureMessage)
  end

  class RaisesNonClassArgument < DohTest::TestGroup
    def test_raises
      assert_raises(ArgumentError, 5) { nil }
    end
  end

  def test_raises_non_class_argument
    verify_argument_error(RaisesNonClassArgument)
  end
end

end
