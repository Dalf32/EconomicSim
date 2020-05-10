# production_rule.rb
#
# Author::  Kyle Mullins

class ProductionRule
  def initialize(commodity, condition_ids)
    @commodity = commodity
    @condition_ids = condition_ids
  end

  def should_produce?(condition_vals)
    @condition_ids.all? { |id| condition_vals[id] }
  end
end
