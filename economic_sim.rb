# economic_sim.rb
#
# Author::  Kyle Mullins

require_relative 'data/data_parser'
require_relative 'data/sim_data'
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
params = DataParser.parse_params(params_file)

params['Resources'].each do |resource_file|
  DataParser.parse_resources(resource_file)
end

Inventory.max_stock = params['MaxStock']

trade_tracker = TradeTracker.new
trade_tracker.register_events
file_logger = FileLogger.new
file_logger.register_events
commodity_tracker = CommodityTracker.new
commodity_tracker.register_events

market = Market.new(SimData.instance.commodities, trade_tracker)
spawner = AgentSpawner.new(market, trade_tracker, SimData.instance.agent_roles,
                           params['StartingFunds'])

commodity_tracker.set_commodities(SimData.instance.commodities)

simulation = Simulation.new(market, spawner,params['NumAgents'])
simulation.run(params['NumRounds'])

SimData.instance.commodities.each do |commodity|
  puts "#{commodity.name} = #{market.last_price_of(commodity)}"
  market.purchase_history[commodity].each { |round_ary| print "#{round_ary.length} " }
  puts
end
