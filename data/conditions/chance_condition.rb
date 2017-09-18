# chance_condition.rb
#
# Author::  Kyle Mullins

class ChanceCondition
  attr_reader :id

  def initialize(id, chance)
    @id = id
    @chance = chance
  end

  def evaluate(_agent)
    rand < @chance
  end
end
