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
    roles = profitable_roles
    roles = @agent_roles if roles.empty?

    spawn_agents(num_agents, roles)
  end

  def most_profitable_role
    @agent_roles.max_by { |role| @trade_tracker.profitability_of(role) }
  end

  def profitable_roles
    @agent_roles.select { |role| @trade_tracker.profitability_of(role).positive? }
  end

  def get_profitability_ratios
    total_profitability = 0
    profitability_ratios = {}

    @agent_roles.each do |agent_role|
      profitability = @trade_tracker.profitability_of(agent_role)
      total_profitability += profitability
      profitability_ratios[agent_role] = profitability
    end

    @agent_roles.each do |agent_role|
      next if profitability_ratios[agent_role].zero?
      profitability_ratios[agent_role] /= total_profitability
    end

    profitability_ratios.sort_by { |_key, value| value }.reverse
  end

  private

  def spawn_agents(num_agents, roles)
    num_agents.times.map { |n| roles[n % roles.count].new_agent(@market, *@agent_params) }
  end
end