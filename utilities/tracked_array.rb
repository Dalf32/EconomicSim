#tracked_array.rb

class TrackedArray < Array
  attr_reader :sum

  def initialize
    super
    @sum = 0
  end

  def avg
    return (@sum / size) unless size == 0
    0
  end

  def <<(value)
    if value.class == TrackedArray
      @sum += value.avg
    else
      @sum += value
    end

    super
  end
end