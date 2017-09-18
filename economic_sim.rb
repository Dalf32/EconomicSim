# economic_sim.rb
#
# Author::  Kyle Mullins

require_relative 'data/sim_data_builder'
require_relative 'data/inventory'
require_relative 'observers/trade_tracker'
require_relative 'observers/file_logger'
require_relative 'observers/commodity_tracker'
require_relative 'simulation/simulation'
require_relative 'simulation/market'
require_relative 'simulation/agent_spawner'

# MAIN

if ARGV.empty?
  puts 'Usage: economic_sim.rb <Params_file.json>'
  exit
end

params_file = ARGV.first
sim_data = SimDataBuilder.from_file(params_file)

Inventory.max_stock = sim_data.max_stock

trade_tracker = TradeTracker.new
trade_tracker.register_events
file_logger = FileLogger.new
file_logger.register_events
commodity_tracker = CommodityTracker.new(sim_data.commodities)
commodity_tracker.register_events

market = Market.new(sim_data.commodities, trade_tracker)
spawner = AgentSpawner.new(market, trade_tracker, sim_data.agent_roles,
                           sim_data.starting_funds)

simulation = Simulation.new(market, spawner, sim_data.num_agents)
simulation.run(sim_data.num_rounds)

sim_data.commodities.each do |commodity|
  puts "#{commodity.name} = #{market.last_price_of(commodity)}"
  print market.purchase_history[commodity].map(&:length).join(' ')
  puts
end
