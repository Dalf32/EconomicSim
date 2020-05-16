# frozen_string_literal: true

# sim_data.rb
#
# Author::  Kyle Mullins

# Holds data that defines this simulation
class SimData
  attr_accessor :num_rounds, :num_agents, :starting_funds, :max_stock

  # Creates new SimData
  def initialize
    @commodities = {}
    @agent_roles = {}
  end

  # All Commodities that are traded in this simulation
  #
  # @return [Array<Commodity>]
  def commodities
    @commodities.values
  end

  # Adds a Commodity to the simulation
  #
  # @param commodity [Commodity] The Commodity to be added
  def add_commodity(commodity)
    @commodities[commodity.name] = commodity
  end

  # Gets a Commodity by name
  #
  # @param commodity_name [String] Name of a Commodity
  # @return [Commodity, NilClass] Commodity with the given name or nil if none
  # match
  def get_commodity(commodity_name)
    @commodities[commodity_name]
  end

  # All AgentRoles that trade in this simulation
  #
  # @return [Array<AgentRole>]
  def agent_roles
    @agent_roles.values
  end

  # Adds an AgentRole to the simulation
  #
  # @param agent_role [AgentRole] AgentRole to be added
  def add_agent_role(agent_role)
    @agent_roles[agent_role.name] = agent_role
  end

  # Gets an AgentRole by name
  #
  # @param agent_role_name [String] Name of a role
  # @return [AgentRole, NilClass] AgentRole with the given name or nil if none
  # match
  def get_agent_role(agent_role_name)
    @agent_roles[agent_role_name]
  end
end
