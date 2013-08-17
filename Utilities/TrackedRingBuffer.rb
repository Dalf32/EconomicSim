#TrackedRingBuffer.rb

require_relative 'TrackedArray'

class TrackedRingBuffer < TrackedArray
  attr_reader :buffer_size

  def initialize(buffer_size)
    super()
    @buffer_size = buffer_size
  end

  def <<(value)
    if size == @buffer_size
      removed = shift

      if removed.class == TrackedArray
        @sum -= removed.avg
      else
        @sum -= removed
      end
    end

    super
  end
end