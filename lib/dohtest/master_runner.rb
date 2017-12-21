require 'dohtest/group_runner'
require 'dohtest/require_paths'

module DohTest

class MasterRunner
  def initialize(output, config, paths)
    @output = output
    @config = config
    @paths = paths
  end

  def run
    start_time = Time.now
    @config[:pre_test_callback].each do |callback|
      callback.call(@output)
    end
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
    # sort them to be the same order no matter what (different machines were returning different results)
    TestGroup.descendants.sort{|a,b|a.to_s<=>b.to_s}.shuffle.each do |group_class|
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
