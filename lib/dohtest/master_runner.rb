require 'dohtest/group_runner'
require 'dohtest/load_test_files'

module DohTest

class MasterRunner
  def initialize(output, config)
    @output = output
    @config = config
  end

  def run
    start_time = Time.now
    srand(@config[:seed])
    @output.run_begin(@config)

    if @config[:test_files].empty?
      @output.no_tests_found
      return 1
    end

    DohTest.load_test_files(@config[:test_files])

    @config[:pre_test_callback].each do |callback|
      callback.call(@output)
    end

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
