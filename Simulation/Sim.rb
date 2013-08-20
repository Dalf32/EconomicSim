#Sim.rb

require_relative 'Market'
require_relative 'AgentSpawner'
require_relative '../EconomicAgent'
require_relative '../AgentRole'
require_relative '../Conditions'
require_relative '../Variables'
require_relative '../ProductionRule'
require_relative '../Data/Commodity'
require_relative '../Data/DataParsing'
require_relative '../Observers/TradeTracker'
require_relative '../Observers/FileLogger'
require_relative '../Observers/CommodityTracker'

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

#MAIN
params_file = ARGF.filename
params = DataParser.parse_params(params_file)

resources = params['Resources']
num_rounds = params['NumRounds']
num_agents = params['NumAgents']
starting_funds = params['StartingFunds']
max_stock = params['MaxStock']

resources.each{|resource_file|
  DataParser.parse_spec(resource_file)
}

Inventory.max_stock = max_stock
market = Market.new(Commodities.all)
spawner = AgentSpawner.new(market, SimData.instance.agent_roles, starting_funds)
agents = spawner.spawn_agents(num_agents)

#Event subscriptions
market.trade_cleared_event<<TradeTracker.instance
market.round_change_event<<TradeTracker.instance

market.trade_cleared_event<<FileLogger.instance
market.round_change_event<<FileLogger.instance

market.trade_cleared_event<<CommodityTracker.instance
market.round_change_event<<CommodityTracker.instance
market.ask_posted_event<<CommodityTracker.instance
market.bid_posted_event<<CommodityTracker.instance

CommodityTracker.instance.set_commodities(Commodities.all)

num_rounds.times{|n|
  puts "Round #{n + 1} start"

  agents.each{|agent|
    agent.perform_production
    agent.generate_asks
    agent.generate_bids
  }

  market.resolve_all_offers

  deleted = agents.reject!{|agent| agent.funds < 0}
  puts agents.size

  unless deleted == nil
    num_deleted = (num_agents - deleted.size)
    puts num_deleted
    new_agents = spawner.spawn_profitable_agents(num_deleted)
    agents += new_agents
  end
}

market.round_change_event.fire

Commodities.all.each{|commodity|
  puts "#{commodity.name} = #{market.last_price_of(commodity)}"
  market.purchase_history[commodity].each{|round_ary|
    print "#{round_ary.length} "
  }
  puts
}
