require 'doh/test/test_group'

module DohTest

class GroupRunner
  def initialize(group_class, output, config = nil)
    @group_class,@output = group_class,output
    @config = config || {}
    @group_name = @group_class.to_s
    @before_all_failed = false
    @error_count = @tests_ran = @tests_skipped = @assertions_failed = @assertions_passed = 0
  end

  def run
    @output.group_begin(@group_name)
    if create_group
      run_before_all
      run_tests unless @before_all_failed
      run_after_all
    end
    @output.group_end(@group_name, @tests_ran, @tests_skipped, @assertions_passed, @assertions_failed)
    past_brink?
  end

  def create_group
    @group = @group_class.new
  rescue => error
    caught_error(error, 'initialize')
    false
  else
    @group.runner = self
    true
  end

  def run_before_all
    @group.before_all if @group.respond_to?(:before_all)
    if @config[:pre_group_callback]
      if (!@config[:pre_group_callback].call())
        @error_count += 1
        @output.callback_failed(@config[:pre_group_callback].inspect)
      end
    end
  rescue => error
    @before_all_failed = true
    caught_error(error, 'before_all')
  end

  def run_after_all
    @group.after_all if @group.respond_to?(:after_all)
    if @config[:post_group_callback]
      if (!@config[:post_group_callback].call())
        @error_count += 1
        @output.callback_failed(@config[:post_group_callback].inspect)
      end
    end
  rescue => error
    caught_error(error, 'after_all')
  end

  def find_before_each_method
    has_before_each = @group.respond_to?(:before_each)
    has_setup = @group.respond_to?(:setup)
    if has_before_each && has_setup
      raise ":before_each and :setup both defined; please pick one"
    elsif has_before_each
      @before_each_method = :before_each
    elsif has_setup
      @before_each_method = :setup
    else
      @before_each_method = nil
    end
  end

  def find_after_each_method
    has_after_each = @group.respond_to?(:after_each)
    has_teardown = @group.respond_to?(:teardown)
    if has_after_each && has_teardown
      raise ":after_each and :teardown both defined; please pick one"
    elsif has_after_each
      @after_each_method = :after_each
    elsif has_teardown
      @after_each_method = :teardown
    else
      @after_each_method = nil
    end
  end

  def run_before_each
    @group.send(@before_each_method)
  rescue => error
    @before_each_failed = true
    caught_error(error)
  end

  def run_after_each
    @group.send(@after_each_method)
  rescue => error
    caught_error(error)
  end

  def run_test_method
    @group.send(@test_name)
  rescue DohTest::Failure => failure
    @assertions_failed += 1
    @output.assertion_failed(@group_name, @test_name, failure)
  rescue => error
    caught_error(error)
  end

  def setup_brink
    @max_errors = if @config.key?(:max_errors) then @config[:max_errors].to_i else nil end
    @max_failures = if @config.key?(:max_failures) then @config[:max_failures].to_i else nil end
    @has_brink = @max_errors || @max_failures
  end

  def past_brink?
    (@max_errors && (@error_count > @max_errors)) || (@max_failures && (@assertions_failed > @max_failures))
  end

  def run_tests
    determine_test_methods
    find_before_each_method
    find_after_each_method
    setup_brink

    @test_methods.each do |method_name|
      break if @has_brink && past_brink?
      @test_name = method_name
      @before_each_failed = false
      @output.test_begin(@group_name, @test_name)
      run_before_each if @before_each_method
      run_test_method unless @before_each_failed
      run_after_each if @after_each_method
      @tests_ran += 1
      @output.test_end(@group_name, @test_name)
    end
  end

  def determine_test_methods
    @test_methods = @group_class.public_instance_methods.grep(/^test/)
    return unless @config.key?(:grep)
    original_test_count = @test_methods.size
    grep_filter = Regexp.new(@config[:grep])
    @test_methods.select! { |method| method.to_s =~ grep_filter }
    @tests_skipped = original_test_count - @test_methods.size
  end

  def assertion_passed
    @assertions_passed += 1
    @output.assertion_passed(@group_name, @test_name)
  end

  def caught_error(error, test_name = nil)
    @error_count += 1
    @output.test_error(@group_name, test_name || @test_name, error)
  end
end

end
