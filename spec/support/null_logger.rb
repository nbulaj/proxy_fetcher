require 'logger'

class NullLogger < Logger
  def initialize(*)
  end

  def add(*)
  end
end
