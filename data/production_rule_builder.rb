# production_rule_builder.rb
#
# Author::  Kyle Mullins

require_relative 'sim_data'
require_relative 'rules/rules'

class ProductionRuleBuilder
  def self.from_hash(rule_hash, sim_data)
    commodity = sim_data.get_commodity(rule_hash['Commodity'])
    condition_ids = rule_hash['Conditions']

    case rule_hash['Amount']
    when 'Variable'
      variable_id = rule_hash['Variable']
      VariableProductionRule.new(commodity, condition_ids, variable_id)
    else
      amount = rule_hash['Amount']
      FixedProductionRule.new(commodity, condition_ids, amount)
    end
  end
end
