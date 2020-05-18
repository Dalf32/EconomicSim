# frozen_string_literal: true

# simulation.rb
#
# Author::  Kyle Mullins

require_relative '../data/sim_data'
require_relative '../events/event_reactor'
require_relative '../events/events'

# Simulates Agents trading in a marketplace
class Simulation

  # Creates a new Simulation
  #
  # @param market [Market] Resolves trades
  # @param agent_spawner [AgentSpawner] Creates Agents
  # @param num_agents [Numeric] The number of Agents to maintain in the simulation
  def initialize(market, agent_spawner, num_agents)
    @market = market
    @agent_spawner = agent_spawner
    @num_agents = num_agents
  end

  # Simulates the marketplace for a number of rounds
  #
  # @param num_rounds [Numeric] The number of rounds to simulate
  def run(num_rounds)
    EventReactor.instance.is_synchronous = true
    agents = @agent_spawner.spawn_all_agents(@num_agents)

    num_rounds.times do |n|
      puts "Round #{n + 1} start"

      sim_round(agents)

      agents = agents.reject(&:bankrupt?)
      puts agents.size

      num_deleted = (@num_agents - agents.size)
      puts num_deleted

      agents += @agent_spawner.spawn_profitable_agents(num_deleted)
    end

    EventReactor.pub(RoundChangeEvent.new)
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
