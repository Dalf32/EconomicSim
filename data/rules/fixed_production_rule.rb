# fixed_production_rule.rb
#
# Author::  Kyle Mullins

require_relative 'production_rule'

class FixedProductionRule < ProductionRule
  def initialize(commodity, condition_ids, amount)
    super(commodity, condition_ids)

    @amount = amount
  end

  def produce(agent, condition_vals, _variable_vals)
    return unless should_produce?(condition_vals)

    agent.inventory.change_stock_of(@commodity, @amount)
  end
end
