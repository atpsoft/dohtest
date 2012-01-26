module DohTest

class BacktraceParser
  def initialize(backtrace)
    @backtrace = backtrace
  end

  def relevant_stack
    @relevant_stack ||= find_relevant_stack
  end

  def summary
    @summary ||= build_summary
  end

private
  def find_relevant_stack
    retval = []
    found_start = false
    @backtrace.each do |location|
      has_doh_test = location.index('doh/test')
      if found_start && has_doh_test
        break
      elsif has_doh_test
        # just ignore it and continue
      else
        found_start = true
        info = location.rpartition(':in').first
        retval << info
      end
    end
    retval
  end

  def build_summary
    retval = ''
    prev_filename = ''
    prev_simplified = ''
    relevant_stack.each do |location|
      parts = location.partition(':')
      filename = File.basename(parts.first)
      simplified = "#{filename}:#{parts.last}"
      raise "unexpected location format: #{location}" unless filename
      if simplified == prev_simplified
        # ignore it
      elsif filename == prev_filename
        retval += ",#{parts.last}"
      elsif retval.empty?
        retval = simplified
      else
        retval += ";#{simplified}"
      end
      prev_filename = filename
      prev_simplified = simplified
    end
    retval
  end
end

def self.backtrace_summary(excpt)
  BacktraceParser.new(excpt.backtrace).summary
end

end
