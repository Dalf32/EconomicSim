# tracked_ring_buffer.rb

require_relative 'tracked_array'

class TrackedRingBuffer < TrackedArray
  attr_reader :buffer_size

  def initialize(buffer_size)
    super()
    @buffer_size = buffer_size
  end

  def <<(value)
    if size == @buffer_size
      removed = shift

      @sum -= removed.class == TrackedArray ? removed.avg : removed
    end

    super
  end
end