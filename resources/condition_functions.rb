# frozen_string_literal: true

# ConditionFunctions
#
# AUTHOR::  Kyle Mullins

# Predicate functions to be used as Conditions for AgentRole logic
module ConditionFunctions
  def has_commodity(commodity)
    inventory.stock_of?(commodity)
  end

  def has_no_commodity(commodity)
    !inventory.stock_of?(commodity)
  end

  def chance(chance)
    rand < chance
  end
end
