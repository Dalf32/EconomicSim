#AgentSpawner.rb

require_relative '../Observers/TradeTracker'

class AgentSpawner
  def initialize(market, agent_roles, *params)
    @market = market
    @agent_roles = agent_roles
    @agent_params = params
  end

  def spawn_agents(num_agents)
    spawned_agents = Array.new
    agent_index = 0

    while spawned_agents.size < num_agents
      agent_role = @agent_roles[agent_index % @agent_roles.size]
      spawned_agents<<agent_role.new_agent(@market, *@agent_params)
      agent_index += 1
    end

    spawned_agents
  end

  def spawn_profitable_agents(num_agents)
    spawned_agents = Array.new
    agent_role = get_most_profitable

    while spawned_agents.size < num_agents
      spawned_agents<<agent_role.new_agent(@market, *@agent_params)
    end

    ratios = get_profitability_ratios
    spawned_agents
  end

  def get_most_profitable
    most_profitable_type = nil
    max_profitability = -Float::MAX

    @agent_roles.each{|agent_role|
      profitability = TradeTracker.instance.profitability_of(agent_role)

      if profitability > max_profitability
        most_profitable_type = agent_role
        max_profitability = profitability
      end
    }

    most_profitable_type
  end

  def get_profitability_ratios
    total_profitability = 0
    profitability_ratios = Hash.new

    @agent_roles.each{|agent_role|
      profitability = TradeTracker.instance.profitability_of(agent_role)
      total_profitability += profitability
      profitability_ratios[agent_role] = profitability
    }

    @agent_roles.each{|agent_role|
      profitability_ratios[agent_role] /= total_profitability unless profitability_ratios[agent_role] == 0
    }

    profitability_ratios.sort_by{|_key, value| value}.reverse
  end
end