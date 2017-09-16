# chance_condition.rb
#
# Author::  Kyle Mullins

class ChanceCondition
  def initialize(chance)
    @chance = chance
  end

  def evaluate(_agent)
    rand < @chance
  end
end
