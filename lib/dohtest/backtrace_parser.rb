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
        parts = info.partition(':')
        raise "unexpected backtrace element: #{location}" if parts.first.nil? || parts.last.nil?
        retval << [parts.first, parts.last]
      end
    end
    retval
  end

  def build_summary
    retval = ''
    prev_filename = ''
    prev_simplified = ''
    relevant_stack.each do |path, line_number|
      filename = File.basename(path)
      simplified = "#{filename}:#{line_number}"
      if simplified == prev_simplified
        # ignore it
      elsif filename == prev_filename
        retval += ",#{line_number}"
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
