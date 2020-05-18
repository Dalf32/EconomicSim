# frozen_string_literal: true

# extensions.rb
#
# Author::  Kyle Mullins

class Array

  # Calculates the average value of the Array (assuming all values are Numeric)
  #
  # @return [Numeric]
  def avg
    return 0 if size.zero?

    sum / size.to_f
  end
end

module Math

  # Calculates the average of the given values
  #
  # @param vals [Array<Numeric>] List of values for which to find the average
  # @return [Numeric]
  def self.avg(*vals)
    vals.sum / vals.count.to_f
  end
end
