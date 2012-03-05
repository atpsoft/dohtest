module DohTest

class Failure < StandardError
  attr_reader :assert, :expected, :actual

  def initialize(message, assert, expected, actual)
    super(message || '')
    @assert, @expected, @actual = assert, expected, actual
  end
end

end
