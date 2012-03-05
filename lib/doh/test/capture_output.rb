module DohTest

class CaptureOutput
  attr_reader :events

  def initialize
    @events = []
  end

  def run_begin(config)
    add(:config => config)
  end

  def run_end(duration)
    add(:duration => duration)
  end

  def group_begin(group_name)
    add(:group_name => group_name)
  end

  def group_end(group_name, tests_ran, tests_skipped, assertions_passed, assertions_failed)
    add(:group_name => group_name, :tests_ran => tests_ran, :tests_skipped => tests_skipped, :assertions_passed => assertions_passed, :assertions_failed => assertions_failed)
  end

  def test_begin(group_name, test_name)
    add(:group_name => group_name, :test_name => test_name)
  end

  def test_end(group_name, test_name)
    add(:group_name => group_name, :test_name => test_name)
  end

  def test_error(group_name, test_name, error)
    add(:group_name => group_name, :test_name => test_name, :error => error)
  end

  def assertion_failed(group_name, test_name, failure)
    add(:group_name => group_name, :test_name => test_name, :failure => failure)
  end

  def assertion_passed(group_name, test_name)
    add(:group_name => group_name, :test_name => test_name)
  end

private
  def add(args)
    args[:name] = caller.first.rpartition(':in ').last[1..-2]
    @events.push(args)
  end
end

end
