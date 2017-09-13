# conditions.rb
#
# Author::  Kyle Mullins

class Condition
end

class ChanceCondition < Condition
  def initialize(chance)
    @chance = chance
  end

  def evaluate(_agent)
    rand < @chance
  end
end

class HasCommodityCondition < Condition
  def initialize(commodity)
    @commodity = commodity
  end

  def evaluate(agent)
    agent.inventory.stock_of?(@commodity)
  end
end
