require 'dohroot'; Doh.find_root_from_file
require 'minitest/autorun'
require 'dohtest/master_runner'
require 'dohtest/capture_output'

module DohTest

class TestMasterRunner < Minitest::Test
  def test_no_tests_found
    output = CaptureOutput.new
    runner = MasterRunner.new(output, DohTest.config.merge(:test_files => [], :seed => 1))
    assert_equal(1, runner.run)
    events = output.events
    assert_equal(2, events.size)
    assert_equal('run_begin', events.shift[:name])
    assert_equal('no_tests_found', events.shift[:name])
  end
end

end
