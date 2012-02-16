require 'doh/test/group_runner'
require 'doh/test/require_paths'

module DohTest

class MasterRunner
  def initialize(output, config, paths)
    @output, @config, @paths = output, config, paths
  end

  def run
    DohTest::require_paths(@config[:glob], @paths)
    srand(@config[:seed])
    @output.run_begin(@config)
    TestGroup.descendants.each { |group_class| GroupRunner.new(group_class, @output, @config).run }
    @output.run_end
  end
end

end
