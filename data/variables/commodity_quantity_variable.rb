# commodity_quantity_variable.rb
#
# Author::  Kyle Mullins

class CommodityQuantityVariable
  def initialize(commodity)
    @commodity = commodity
  end

  def evaluate(agent)
    agent.inventory.stock_of(@commodity)
  end
end
