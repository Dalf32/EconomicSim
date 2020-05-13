# agent_spawner.rb
#
# Author::  Kyle Mullins

class AgentSpawner
  def initialize(market, trade_tracker, agent_roles, *params)
    @market = market
    @trade_tracker = trade_tracker
    @agent_roles = agent_roles
    @agent_params = params
  end

  def spawn_all_agents(num_agents)
    spawn_agents(num_agents, @agent_roles)
  end

  def spawn_profitable_agents(num_agents)
    ratios = profitability_ratios
    return spawn_agents(num_agents, @agent_roles) if ratios.empty?

    spawned_agents = ratios.each_pair.map do |role, profitability|
      spawn_agents((profitability * num_agents).to_i, role)
    end.flatten
    remainder = num_agents - spawned_agents.count

    spawned_agents + spawn_agents(remainder, ratios.keys)
  end

  def most_profitable_role
    @agent_roles.max_by { |role| @trade_tracker.profitability_of(role) }
  end

  def profitable_roles
    @agent_roles.select { |role| @trade_tracker.profitability_of(role).positive? }
  end

  private

  def profitability_ratios
    total_profitability = 0
    profitability_ratios = {}
    roles = profitable_roles

    roles.each do |agent_role|
      profitability = @trade_tracker.profitability_of(agent_role)
      total_profitability += profitability
      profitability_ratios[agent_role] = profitability
    end

    roles.each do |agent_role|
      profitability_ratios[agent_role] /= total_profitability
    end

    profitability_ratios
  end

  def spawn_agents(num_agents, roles)
    return num_agents.times.map { spawn_agent(roles) } if roles.is_a?(AgentRole)

    num_agents.times.map { |n| spawn_agent(roles[n % roles.count]) }
  end

  def spawn_agent(role)
    role.new_agent(@market, *@agent_params)
  end
end