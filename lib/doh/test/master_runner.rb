require 'doh/test/group_runner'
require 'doh/test/require_paths'

module DohTest

class MasterRunner
  def initialize(output, config, paths)
    @output, @config, @paths = output, config, paths
  end

  def run
    start_time = Time.now
    @config[:pre_test_callback].call(@output) if @config[:pre_test_callback]
    DohTest::require_paths(@config[:glob], @paths)
    srand(@config[:seed])
    @output.run_begin(@config)
    total_problems = 0
    TestGroup.descendants.each do |group_class|
      runner = GroupRunner.new(group_class, @output, @config)
      brink_hit = runner.run
      total_problems += runner.total_problems
      break if brink_hit
    end
    if @config[:post_all_callback]
      if (!@config[:post_all_callback].call(total_problems))
        @output.callback_failed(@config[:post_all_callback].inspect)
      end
    end
    @output.run_end(Time.now - start_time)
  end
end

end
