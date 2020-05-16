# frozen_string_literal: true

# price_belief.rb
#
# Author::  Kyle Mullins

require_relative '../utilities/extensions'

# Represents an Agent's perceived value of something
class PriceBelief
  MIN_SPAN = 2.0
  MIN_PRICE = 0.01
  attr_reader :min, :max

  # Creates a new PriceBelief
  #
  # @param min [Numeric] Minimum perceived price
  # @param max [Numeric] Maximum perceived price
  def initialize(min, max)
    @min = min
    @max = max
  end

  # Selects a price somewhere within the belief range
  #
  # @return [Numeric] Randomly determined price within belief range
  def choose_price
    @min + rand(@max - @min)
  end

  # Narrows the belief range by the given amount on both ends, provided the new
  # range spans at least as much as #MIN_SPAN
  #
  # @param narrow_amount [Numeric] Amount by which to narrow the range
  def narrow(narrow_amount)
    new_min = @min + narrow_amount
    new_max = @max - narrow_amount
    new_belief = PriceBelief.new(new_min, new_max)

    return if new_belief.span < MIN_SPAN

    @min = new_min
    @max = new_max
  end

  # Expands the belief range by the given amount on both ends, provided the new
  # minimum is greater than or equal to #MIN_PRICE
  #
  # @param expand_amount [Numeric] Amount by which to expand the range
  def expand(expand_amount)
    new_min = @min - expand_amount

    @min = new_min unless new_min <= MIN_PRICE
    @max += expand_amount
  end

  # Shifts the entire belief range by the given amount, provided the new bounds
  # are greater than or equal to #MIN_PRICE
  #
  # @param amount [Numeric] Amount by which to translate the range
  def translate(amount)
    new_min = @min + amount
    new_max = @max + amount

    @min = new_min unless new_min <= MIN_PRICE
    @max = new_max unless new_max <= MIN_PRICE
  end

  # The full span of the belief range
  #
  # @return [Numeric]
  def span
    @max - @min
  end

  # Mid-point of the belief range
  #
  # @return [Numeric]
  def mean
    Math.avg(@min, @max)
  end
end
