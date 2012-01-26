require 'doh/test/configure'
require 'doh/test/group_runner'
require 'doh/test/require_paths'

module DohTest

class MasterRunner
  def initialize(output, config)
    @output, @config = output, config
    add_missing_config
  end

  def run
    paths = @config[:paths]
    DohTest::configure(paths[0])
    DohTest::require_paths(@config[:glob], paths)
    srand(@config[:seed])
    @output.run_begin(@config)
    TestGroup.descendants.each { |group_class| GroupRunner.new(group_class, @output, @config).run }
    @output.run_end
  end

private
  def add_missing_config
    @config[:glob] ||= '*.dt.rb'
    @config[:seed] ||= (Time.new.to_f * 1000).to_i
    @config[:paths] ||= ['.']
  end
end

end
