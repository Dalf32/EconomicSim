#production_rule.rb

class ProductionRule
  def initialize(commodity, condition_ids)
    @commodity = commodity
    @condition_ids = condition_ids
  end

  def should_produce?(condition_vals)
    should_produce = true

    @condition_ids.each{|id|
      should_produce &= condition_vals[id]
    }

    should_produce
  end
end

class FixedProductionRule < ProductionRule
  def initialize(commodity, condition_ids, amount)
    super(commodity, condition_ids)

    @amount = amount
  end

  def produce(agent, condition_vals, _variable_vals)
    if should_produce?(condition_vals)
      agent.inventory.change_stock_of(@commodity, @amount)
    end
  end
end

class VariableProductionRule < ProductionRule
  def initialize(commodity, condition_ids, amount_var_id)
    super(commodity, condition_ids)

    @amount_variable_id = amount_var_id
  end

  def produce(agent, condition_vals, variable_vals)
    if should_produce?(condition_vals)
      agent.inventory.change_stock_of(@commodity, variable_vals[@amount_variable_id])
    end
  end
end
