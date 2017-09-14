# has_commodity_condition.rb
#
# Author::  Kyle Mullins

class HasCommodityCondition
  def initialize(commodity)
    @commodity = commodity
  end

  def evaluate(agent)
    agent.inventory.stock_of?(@commodity)
  end
end
