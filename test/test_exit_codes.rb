require 'dohroot'; Doh.find_root_from_file
require 'minitest/autorun'
require 'tmpdir'

module DohTest

# runs bin/dohtest and bin/dohtest_repeat as subprocesses against generated
# fixture suites, pinning the exit-code contract: 0 only when tests ran and
# every assertion passed, 1 otherwise
class TestExitCodes < Minitest::Test
  BIN_DIR = File.join(Doh.root, 'bin')
  LIB_DIR = File.join(Doh.root, 'lib')

  PASSING_GROUP = <<~EOT
    class TestExitPass < DohTest::TestGroup
      def test_pass
        assert_equal(4, 2 + 2)
      end
    end
  EOT

  FAILING_GROUP = <<~EOT
    class TestExitFail < DohTest::TestGroup
      def test_pass
        assert_equal(4, 2 + 2)
      end
      def test_fail
        assert_equal(5, 2 + 2)
      end
    end
  EOT

  ERROR_GROUP = <<~EOT
    class TestExitError < DohTest::TestGroup
      def test_error
        raise 'boom'
      end
    end
  EOT

  NO_ASSERTION_GROUP = <<~EOT
    class TestExitNoAssertions < DohTest::TestGroup
      def test_nothing
      end
    end
  EOT

  def run_dohtest(path)
    system('ruby', "-I#{LIB_DIR}", File.join(BIN_DIR, 'dohtest'), '-q', path, :out => File::NULL, :err => File::NULL)
    return $?.exitstatus
  end

  def run_dohtest_repeat(path)
    env = {'PATH' => "#{BIN_DIR}:#{ENV['PATH']}", 'RUBYLIB' => LIB_DIR}
    system(env, 'ruby', File.join(BIN_DIR, 'dohtest_repeat'), '-q', path, :out => File::NULL, :err => File::NULL)
    return $?.exitstatus
  end

  def with_fixture(group_source)
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'dohroot'), '')
      path = File.join(dir, 'fixture.dt.rb')
      File.write(path, group_source)
      yield path
    end
  end

  def test_all_assertions_passing_exits_zero
    with_fixture(PASSING_GROUP) do |path|
      assert_equal(0, run_dohtest(path))
    end
  end

  def test_assertion_failure_exits_one
    with_fixture(FAILING_GROUP) do |path|
      assert_equal(1, run_dohtest(path))
    end
  end

  def test_error_exits_one
    with_fixture(ERROR_GROUP) do |path|
      assert_equal(1, run_dohtest(path))
    end
  end

  def test_no_assertions_exits_one
    with_fixture(NO_ASSERTION_GROUP) do |path|
      assert_equal(1, run_dohtest(path))
    end
  end

  def test_no_test_files_exits_one
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'dohroot'), '')
      assert_equal(1, run_dohtest(dir))
    end
  end

  def test_dohtest_repeat_propagates_failure
    with_fixture(FAILING_GROUP) do |path|
      assert_equal(1, run_dohtest_repeat(path))
    end
  end
end

end
