# agent_role_builder.rb
#
# Author::  Kyle Mullins

require_relative 'sim_data'
require_relative 'agent_role'
require_relative 'condition_builder'
require_relative 'variable_builder'
require_relative 'production_rule_builder'

class AgentRoleBuilder
  def self.from_hash(agent_hash)
    name = agent_hash['Name']
    role = AgentRole.new(name, SimData.instance.commodities)

    agent_hash.each_pair do |key, value|
      case key
      when 'Name'
        next
      when 'Conditions'
        value.each do |condition_hash|
          ConditionBuilder.from_hash(condition_hash).each_pair do |id, condition|
            role.add_condition(id, condition)
          end
        end
      when 'Variables'
        value.each do |variable_hash|
          VariableBuilder.from_hash(variable_hash).each_pair do |id, variable|
            role.add_variable(id, variable)
          end
        end
      when 'Productions'
        value.each do |rule_hash|
          role.add_production_rule(ProductionRuleBuilder.from_hash(rule_hash))
        end
      when 'Commodities'
        value.each do |preference_hash|
          commodity = SimData.instance.get_commodity(preference_hash['Name'])
          buys = preference_hash['Buys?']
          sells = preference_hash['Sells?']
          ideal_stock = preference_hash['Ideal Stock']

          role.set_commodity_prefs(commodity, ideal_stock, buys, sells)
        end
      else
        raise 'Illegal AgentRole JSON'
      end
    end

    role
  end
end
