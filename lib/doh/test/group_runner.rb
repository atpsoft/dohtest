require 'doh/test/test_group'

module DohTest

class GroupRunner
  def initialize(group_class, output, config = nil)
    @group_class,@output = group_class,output
    @config = config || {}
    @group_name = @group_class.to_s
    @group_failed = false
  end

  def run
    @output.group_begin(@group_name)
    create_group
    run_before_all unless @group_failed
    run_tests unless @group_failed
    run_after_all unless @group_failed
    @output.group_end(@group_name)
  end

  def create_group
    @group = @group_class.new
  rescue => error
    @group_failed = true
    @output.test_error(@group_name, 'initialize', error)
  else
    @group.runner = self
  end

  def run_before_all
    @group.before_all if @group.respond_to?(:before_all)
  rescue => error
    @group_failed = true
    @output.test_error(@group_name, 'before_all', error)
  end

  def run_after_all
    @group.after_all if @group.respond_to?(:after_all)
  rescue => error
    @output.test_error(@group_name, 'after_all', error)
  end

  def run_tests
    determine_test_methods
    has_before_each = @group.respond_to?(:before_each)
    has_after_each = @group.respond_to?(:after_each)

    @test_methods.each do |method_name|
      @test_name = method_name
      begin
        @group.send(:before_each) if has_before_each
        @output.test_begin(@group_name, @test_name)
        @group.send(@test_name)
        @output.test_end(@group_name, @test_name)
        @group.send(:after_each) if has_after_each
      rescue DohTest::AssertionFailed => failure
        @output.assertion_failed(@group_name, @test_name, failure)
      rescue => error
        @output.test_error(@group_name, @test_name, error)
      end
    end
  end

  def determine_test_methods
    @test_methods = @group_class.public_instance_methods.grep(/^test/)
    original_test_count = @test_methods.size
    return unless @config.key?(:grep)
    grep_filter = Regexp.new(@config[:grep])
    @test_methods.select! { |method| name.to_s =~ grep_filter }
    @output.tests_skipped(@group_name, original_test_count - @test_methods.size)
  end

  def assertion_passed
    @output.assertion_passed(@group_name, @test_name)
  end
end

end
