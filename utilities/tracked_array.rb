# tracked_array.rb
#
# Author::  Kyle Mullins

class TrackedArray < Array
  attr_reader :sum

  def initialize
    super
    @sum = 0
  end

  def avg
    return 0 if size.zero?
    (@sum / size)
  end

  def <<(value)
    @sum += value.class == TrackedArray ? value.avg : value

    super
  end
end