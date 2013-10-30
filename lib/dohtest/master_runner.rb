require 'dohtest/group_runner'
require 'dohtest/require_paths'

module DohTest

class MasterRunner
  def initialize(output, config, paths)
    @output, @config, @paths = output, config, paths
  end

  def run
    start_time = Time.now
    @config[:pre_test_callback].call(@output) if @config[:pre_test_callback]
    if @paths.empty?
      unless DohTest.require_paths(@config[:glob], ['.'])
        DohTest.require_paths(@config[:glob], [@config[:root]])
      end
    else
      DohTest.require_paths(@config[:glob], @paths)
    end

    srand(@config[:seed])
    @output.run_begin(@config)
    total_problems = 0
    TestGroup.descendants.each do |group_class|
      runner = GroupRunner.new(group_class, @output, @config)
      brink_hit = runner.run
      total_problems += runner.total_problems
      break if brink_hit
    end
    @config[:post_all_callback].each do |proc|
      if !proc.call(total_problems)
        @output.callback_failed(proc.inspect)
      end
    end
    @output.run_end(Time.now - start_time)
  end
end

end
