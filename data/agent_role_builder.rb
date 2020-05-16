# frozen_string_literal: true

# agent_role_builder.rb
#
# Author::  Kyle Mullins

require_relative 'sim_data'
require_relative 'agent_role'
require_relative 'production_rule'
require_relative 'condition'

# Builds AgentRoles
class AgentRoleBuilder

  # Builds a role from the data in the hash
  #
  # @param agent_hash [Hash] Hash holding all of the role data
  # @param sim_data [SimData] Common store of this simulation's data
  # @return [AgentRole] Newly-constructed role
  def self.from_hash(agent_hash, sim_data)
    name = agent_hash['Name']

    AgentRoleBuilder.new(name, sim_data)
                    .conditions(agent_hash['Conditions'])
                    .productions(agent_hash['Productions'])
                    .commodities(agent_hash['Commodities'])
                    .build
  end

  # Creates a new AgentRole
  #
  # @param name [String] Name of this role
  # @param sim_data [SimData] Common store of this simulation's data
  def initialize(name, sim_data)
    @sim_data = sim_data
    @role = AgentRole.new(name, @sim_data.commodities)
  end

  # Returns the constructed AgentRole
  #
  # @return [AgentRole]
  def build
    @role
  end

  # Builds and adds Conditions from the given hash to the role
  #
  # @param conditions_hash [Hash] Specification of this role's Conditions
  # @return [AgentRoleBuilder] self
  def conditions(conditions_hash)
    return self if conditions_hash.nil?

    conditions_hash.each do |condition_hash|
      @role.add_condition(Condition.from_hash(condition_hash))
    end

    self
  end

  # Builds and adds Production Rules from the given hash to the role
  #
  # @param productions_hash [Hash] Specification of this role's Production Rules
  # @return [AgentRoleBuilder] self
  def productions(productions_hash)
    return self if productions_hash.nil?

    productions_hash.each do |rule_hash|
      @role.add_production_rule(ProductionRule.from_hash(rule_hash))
    end

    self
  end

  # Sets up this role's Commodity preferences from the given hash
  #
  # @param commodities_hash [Hash] Specification of this role's Commodity preferences
  # @return [AgentRoleBuilder] self
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
