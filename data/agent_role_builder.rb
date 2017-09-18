# agent_role_builder.rb
#
# Author::  Kyle Mullins

require_relative 'sim_data'
require_relative 'agent_role'
require_relative 'condition_builder'
require_relative 'variable_builder'
require_relative 'production_rule_builder'

class AgentRoleBuilder
  def self.from_hash(agent_hash, sim_data)
    name = agent_hash['Name']

    builder = AgentRoleBuilder.new(name, sim_data)
                              .conditions(agent_hash['Conditions'])
                              .variables(agent_hash['Variables'])
                              .productions(agent_hash['Productions'])
                              .commodities(agent_hash['Commodities'])

    builder.build
  end

  def initialize(name, sim_data)
    @sim_data = sim_data
    @role = AgentRole.new(name, @sim_data.commodities)
  end

  def build
    @role
  end

  def conditions(conditions_hash)
    return self if conditions_hash.nil?

    conditions_hash.each do |condition_hash|
      condition = ConditionBuilder.from_hash(condition_hash, @sim_data)
      @role.add_condition(condition)
    end

    self
  end

  def variables(variables_hash)
    return self if variables_hash.nil?

    variables_hash.each do |variable_hash|
      variable = VariableBuilder.from_hash(variable_hash, @sim_data)
      @role.add_variable(variable)
    end

    self
  end

  def productions(productions_hash)
    return self if productions_hash.nil?

    productions_hash.each do |rule_hash|
      rule = ProductionRuleBuilder.from_hash(rule_hash, @sim_data)
      @role.add_production_rule(rule)
    end

    self
  end

  def commodities(commodities_hash)
    return self if commodities_hash.nil?

    commodities_hash.each do |preference_hash|
      commodity = @sim_data.get_commodity(preference_hash['Name'])
      buys = preference_hash['Buys?']
      sells = preference_hash['Sells?']
      ideal_stock = preference_hash['Ideal Stock']

      @role.set_commodity_prefs(commodity, ideal_stock, buys, sells)
    end

    self
  end
end