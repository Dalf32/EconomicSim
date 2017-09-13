#SimData.rb

require 'singleton'

class SimData
  include Singleton

  def initialize
    @commodities = Hash.new
    @agent_roles = Hash.new
  end

  def commodities
    @commodities.values
  end

  def add_commodity(commodity)
    @commodities[commodity.name] = commodity
  end

  def get_commodity(commodity_name)
    @commodities[commodity_name]
  end

  def agent_roles
    @agent_roles.values
  end

  def add_agent_role(agent_role)
    @agent_roles[agent_role.name] = agent_role
  end

  def get_agent_role(agent_role_name)
    @agent_roles[agent_role_name]
  end
end