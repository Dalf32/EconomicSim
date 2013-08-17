#Variables.rb

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
    -@variable.evaluate(agent)
  end
end
