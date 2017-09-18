# has_commodity_condition.rb
#
# Author::  Kyle Mullins

class HasCommodityCondition
  attr_reader :id

  def initialize(id, commodity)
    @id = id
    @commodity = commodity
  end

  def evaluate(agent)
    agent.inventory.stock_of?(@commodity)
  end
end
