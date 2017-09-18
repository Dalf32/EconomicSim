# commodity_quantity_variable.rb
#
# Author::  Kyle Mullins

class CommodityQuantityVariable
  attr_reader :id

  def initialize(id, commodity)
    @id = id
    @commodity = commodity
  end

  def evaluate(agent)
    agent.inventory.stock_of(@commodity)
  end
end
