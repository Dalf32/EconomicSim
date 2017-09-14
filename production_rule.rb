# production_rule.rb
#
# Author::  Kyle Mullins

class ProductionRule
  def initialize(commodity, condition_ids)
    @commodity = commodity
    @condition_ids = condition_ids
  end

  def should_produce?(condition_vals)
    should_produce = true

    @condition_ids.each { |id| should_produce &= condition_vals[id] }

    should_produce
  end
end
