#PriceBelief.rb

require_relative '../Utilities/Extensions'

class PriceBelief
  MIN_SPAN = 2.0
  MIN_PRICE = 0.01
  attr_reader :min, :max

  def initialize(min, max)
    @min = min
    @max = max
  end

  def choose_price
    @min + rand(@max - @min)
  end

  def narrow(narrow_amount)
    new_min = @min + narrow_amount
    new_max = @max - narrow_amount
    new_belief = PriceBelief.new(new_min, new_max)

    unless new_belief.span < MIN_SPAN
      @min = new_min
      @max = new_max
    end
  end

  def expand(expand_amount)
    new_min = @min - expand_amount

    @min = new_min unless new_min <= MIN_PRICE
    @max += expand_amount
  end

  def translate(amount)
    new_min = @min + amount
    new_max = @max + amount

    @min = new_min unless new_min <= MIN_PRICE
    @max = new_max unless new_max <= MIN_PRICE
  end

  def span
    @max - @min
  end

  def mean
    Math.avg(@min, @max)
  end
end
