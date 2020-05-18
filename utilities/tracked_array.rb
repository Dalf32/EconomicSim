# frozen_string_literal: true

# tracked_array.rb
#
# Author::  Kyle Mullins

# An Array that keeps a running sum of its elements for increased performance
class TrackedArray < Array
  attr_reader :sum

  # Creates a new empty TrackedArray
  def initialize
    super
    @sum = 0
  end

  # Calculates the average of the elements in the array
  #
  # @return [Numeric]
  def avg
    return 0 if size.zero?

    @sum / size.to_f
  end

  def <<(value)
    @sum += value.is_a?(TrackedArray) ? value.avg : value

    super
  end
end
