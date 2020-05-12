# ConditionFunctions
#
# AUTHOR::  Kyle Mullins

module ConditionFunctions
  def has_commodity(commodity)
    inventory.stock_of?(commodity)
  end

  def chance(chance)
    rand < chance
  end
end
