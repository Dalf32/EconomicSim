# variables.rb
#
# Author::  Kyle Mullins

class Variable
end

class CommodityQuantityVariable < Variable
  def initialize(commodity)
    @commodity = commodity
  end

  def evaluate(agent)
    agent.inventory.stock_of(@commodity)
  end
end

class NegateVariable < Variable
  def initialize(variable)
    @variable = variable
  end

  def evaluate(agent)
    -agent.role.evaluate_variable(agent, @variable)
  end
end
