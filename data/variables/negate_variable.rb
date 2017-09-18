# negate_variable.rb
#
# Author::  Kyle Mullins

class NegateVariable
  attr_reader :id

  def initialize(id, variable)
    @id = id
    @variable = variable
  end

  def evaluate(agent)
    -agent.role.evaluate_variable(agent, @variable)
  end
end
