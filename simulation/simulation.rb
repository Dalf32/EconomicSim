# simulation.rb
#
# Author::  Kyle Mullins

require_relative '../data/sim_data'
require_relative '../events/event_reactor'
require_relative '../events/events'

class Simulation
  def initialize(market, agent_spawner, num_agents)
    @market = market
    @agent_spawner = agent_spawner
    @num_agents = num_agents
  end

  def run(num_rounds)
    agents = @agent_spawner.spawn_agents(@num_agents)

    num_rounds.times do |n|
      puts "Round #{n + 1} start"

      sim_round(agents)

      deleted = agents.reject! { |agent| agent.funds < 0 }
      puts agents.size

      next if deleted.nil?

      num_deleted = (@num_agents - deleted.size)
      puts num_deleted
      new_agents = @agent_spawner.spawn_profitable_agents(num_deleted)
      agents += new_agents
    end

    EventReactor.instance.publish(RoundChangeEvent.new)
  end

  private

  def sim_round(agents)
    agents.each do |agent|
      agent.perform_production
      agent.generate_asks
      agent.generate_bids
    end

    @market.resolve_all_offers
  end
end
