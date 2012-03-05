require 'doh/root'; Doh::find_root_from_file
require 'minitest/autorun'
require 'doh/test/backtrace_parser'

module DohTest

class TestBacktraceParser < MiniTest::Unit::TestCase
  def create_single_stack
    retval = []
    retval << "/Users/somebody/dohtest/lib/doh/test/assertions.rb:10:in `assert'"
    retval << "/Users/somebody/dohtest/lib/doh/test/assertions.rb:15:in `assert_equal'"
    retval << "/Users/somebody/tinker/test/frog.rb:12:in `test_thing'"
    retval << "/Users/somebody/dohtest/lib/doh/test/group_runner.rb:28:in `block in run_group'"
    retval << "/Users/somebody/dohtest/lib/doh/test/group_runner.rb:12:in `each'"
    retval << "/Users/somebody/dohtest/lib/doh/test/group_runner.rb:12:in `run'"
    retval << "/Users/somebody/dohtest/bin/dohtest:24:in `<main>'"
    retval
  end

  def test_single_stack
    parser = DohTest::BacktraceParser.new(create_single_stack)
    assert_equal("frog.rb:12", parser.summary)
  end

  def create_raw_double_stack
    retval = []
    retval << "/Users/somebody/dohtest/lib/doh/test/assertions.rb:10:in `assert'"
    retval << "/Users/somebody/tinker/test/frog.rb:5:in `verify_sum'"
    retval << "/Users/somebody/tinker/test/frog.rb:12:in `test_thing'"
    retval << "/Users/somebody/dohtest/lib/doh/test/group_runner.rb:28:in `block in run_group'"
    retval
  end

  def create_relevant_double_stack
    retval = []
    retval << ['/Users/somebody/tinker/test/frog.rb', '5']
    retval << ['/Users/somebody/tinker/test/frog.rb', '12']
    retval
  end

  def test_double_stack
    parser = DohTest::BacktraceParser.new(create_raw_double_stack)
    assert_equal(create_relevant_double_stack, parser.relevant_stack)
    assert_equal("frog.rb:5,12", parser.summary)
  end

  def create_multifile_stack
    retval = []
    retval << "/Users/somebody/dohtest/lib/doh/test/assertions.rb:10:in `assert'"
    retval << "/Users/somebody/tinker/helpers/toad.rb:8:in `verify_sum'"
    retval << "/Users/somebody/tinker/test/frog.rb:11:in `test_thing'"
    retval << "/Users/somebody/dohtest/lib/doh/test/group_runner.rb:28:in `block in run_group'"
    retval
  end

  def test_multifile_stack
    parser = DohTest::BacktraceParser.new(create_multifile_stack)
    assert_equal("toad.rb:8;frog.rb:11", parser.summary)
  end

  def create_duplicate_stack
    retval = []
    retval << "/Users/somebody/tinker/dtest/blee.rb:30:in `/'"
    retval << "/Users/somebody/tinker/dtest/blee.rb:30:in `test_silly_error'"
    retval << "/Users/somebody/dohtest/lib/doh/test/group_runner.rb:28:in `block in run_group'"
    retval
  end

  def test_duplicate_stack
    parser = DohTest::BacktraceParser.new(create_duplicate_stack)
    assert_equal("blee.rb:30", parser.summary)
  end

  def create_block_stack
    retval = []
    retval << "/Users/somebody/tinker/dtest/kblah.rb:3:in `block in <class:TestKblah>'"
    retval
  end

  def test_block_stack
    parser = DohTest::BacktraceParser.new(create_block_stack)
    assert_equal("kblah.rb:3", parser.summary)
  end
end

end
