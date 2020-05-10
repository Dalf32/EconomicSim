# variable_production_rule.rb
#
# Author::  Kyle Mullins

require_relative 'production_rule'

class VariableProductionRule < ProductionRule
  def initialize(commodity, condition_ids, amount_var_id)
    super(commodity, condition_ids)

    @amount_variable_id = amount_var_id
  end

  def produce(agent, condition_vals, variable_vals)
    return unless should_produce?(condition_vals)

    agent.inventory.change_stock_of(@commodity, variable_vals[@amount_variable_id])
  end
end
