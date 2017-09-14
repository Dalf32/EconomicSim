# sim.rb
#
# Author::  Kyle Mullins

require_relative 'market'
require_relative 'agent_spawner'
require_relative '../economic_agent'
require_relative '../agent_role'
require_relative '../conditions'
require_relative '../variables'
require_relative '../production_rule'
require_relative '../data/commodity'
require_relative '../data/data_parsing'
require_relative '../events/event_reactor'
require_relative '../observers/trade_tracker'
require_relative '../observers/file_logger'
require_relative '../observers/commodity_tracker'

class Commodities
  WHEAT = Commodity.new('Wheat')
  WOOD = Commodity.new('Wood')
  ORE = Commodity.new('Ore')
  METAL = Commodity.new('Metal')
  TOOLS = Commodity.new('Tools')

  def self.all
    [WHEAT, WOOD, ORE, METAL, TOOLS]
  end
end

# MAIN
if ARGV.empty?
  puts 'Usage: sim.rb <Params_file.json>'
  exit
end

params_file = ARGF.filename
params = DataParser.parse_params(params_file)

resources = params['Resources']
num_rounds = params['NumRounds']
num_agents = params['NumAgents']
starting_funds = params['StartingFunds']
max_stock = params['MaxStock']

resources.each { |resource_file|
  DataParser.parse_spec(resource_file)
}

Inventory.max_stock = max_stock

trade_tracker = TradeTracker.new
file_logger = FileLogger.new
commodity_tracker = CommodityTracker.new

market = Market.new(Commodities.all, trade_tracker)
spawner = AgentSpawner.new(market, trade_tracker, SimData.instance.agent_roles, starting_funds)
agents = spawner.spawn_agents(num_agents)

commodity_tracker.set_commodities(Commodities.all)

num_rounds.times do |n|
  puts "Round #{n + 1} start"

  agents.each do |agent|
    agent.perform_production
    agent.generate_asks
    agent.generate_bids
  end

  market.resolve_all_offers

  deleted = agents.reject! { |agent| agent.funds < 0 }
  puts agents.size

  next if deleted.nil?

  num_deleted = (num_agents - deleted.size)
  puts num_deleted
  new_agents = spawner.spawn_profitable_agents(num_deleted)
  agents += new_agents
end

EventReactor.instance.publish(RoundChangeEvent.new)

Commodities.all.each do |commodity|
  puts "#{commodity.name} = #{market.last_price_of(commodity)}"
  market.purchase_history[commodity].each { |round_ary| print "#{round_ary.length} " }
  puts
end
