require 'doh/test/assertions'

module DohTest

class TestGroup
  def self.descendants
    @@descendants ||= []
  end

  def self.inherited(descendant)
    descendants << descendant
  end

  attr_writer :runner
end

end
