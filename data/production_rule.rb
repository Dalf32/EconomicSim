# production_rule.rb
#
# Author::  Kyle Mullins

class ProductionRule
  def self.from_hash(rule_hash)
    function_name = rule_hash['Function'].to_sym
    function = ProductionFunctions.instance_method(function_name)
    parameters = rule_hash['Parameters']
    condition_ids = rule_hash['Conditions']

    ProductionRule.new(function, parameters, condition_ids)
  end

  def initialize(function, parameters, condition_ids)
    @function = function
    @parameters = parameters
    @condition_ids = condition_ids
  end

  def should_produce?(condition_vals)
    @condition_ids.all? { |id| condition_vals[id] }
  end

  def produce(agent, condition_vals)
    return unless should_produce?(condition_vals)

    @function.bind(agent).call(*@parameters)
  end
end
