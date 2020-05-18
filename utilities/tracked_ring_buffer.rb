# frozen_string_literal: true

# tracked_ring_buffer.rb
#
# Author::  Kyle Mullins

require_relative 'tracked_array'

# A ring buffer which keeps a running sum of its elements for increased
# performance. When the maximum size has been reached, the oldest element will
# be removed from the list
class TrackedRingBuffer < TrackedArray
  attr_reader :buffer_size

  # Creates a new empty TrackedRingBuffer
  #
  # @param buffer_size [Numeric] The maximum size of the buffer
  def initialize(buffer_size)
    super()
    @buffer_size = buffer_size
  end

  def <<(value)
    if size == @buffer_size
      removed = shift

      @sum -= removed.is_a?(TrackedArray) ? removed.avg : removed
    end

    super
  end
end
