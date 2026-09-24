require 'dohtest/group_runner'
require 'dohtest/capture_output'

module DohTest

# runs a test group with CaptureOutput, so a Minitest::Test can check the events it reports
module GroupRunnerHelper
  def verify_event(expected_pairs, event)
    expected_pairs.each_pair do |key, value|
      assert_equal(value, event[key])
    end
  end

  def run_group(group_klass, config_overrides = {})
    @group_klass = group_klass
    @output = CaptureOutput.new
    @runner = GroupRunner.new(@group_klass, @output, DohTest.config.merge(config_overrides))
    @runner.run
    @events = @output.events
    assert_equal({:name => 'group_begin', :group_name => @group_klass.to_s}, @events.shift)
    verify_event({:name => 'group_end', :group_name => @group_klass.to_s}, @events.last)
  end
end

end
