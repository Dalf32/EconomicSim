# negate_variable.rb
#
# Author::  Kyle Mullins

class NegateVariable
  def initialize(variable)
    @variable = variable
  end

  def evaluate(agent)
    -agent.role.evaluate_variable(agent, @variable)
  end
end
