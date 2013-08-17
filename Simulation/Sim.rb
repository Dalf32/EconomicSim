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

#Farmer AgentRole
#farmer = AgentRole.new('Farmer', Commodities.all)
#
#farmer.add_condition(1, HasCommodityCondition.new(Commodities::WOOD))
#farmer.add_condition(2, HasCommodityCondition.new(Commodities::TOOLS))
#farmer.add_condition(3, ChanceCondition.new(0.1))
#
#farmer.add_production_rule(FixedProductionRule.new(Commodities::WOOD, [1], -1))
#farmer.add_production_rule(FixedProductionRule.new(Commodities::WHEAT, [1], 2))
#farmer.add_production_rule(FixedProductionRule.new(Commodities::WHEAT, [1, 2], 2))
#farmer.add_production_rule(FixedProductionRule.new(Commodities::TOOLS, [1, 2, 3], -1))
#
#farmer.set_commodity_prefs(Commodities::WHEAT, 140, false, true)
#farmer.set_commodity_prefs(Commodities::WOOD, 40, true, false)
#farmer.set_commodity_prefs(Commodities::ORE, 0, false, false)
#farmer.set_commodity_prefs(Commodities::METAL, 0, false, false)
#farmer.set_commodity_prefs(Commodities::TOOLS, 5, true, false)
#
##Miner AgentRole
#miner = AgentRole.new('Miner', Commodities.all)
#
#miner.add_condition(1, HasCommodityCondition.new(Commodities::WHEAT))
#miner.add_condition(2, HasCommodityCondition.new(Commodities::TOOLS))
#miner.add_condition(3, ChanceCondition.new(0.1))
#
#miner.add_production_rule(FixedProductionRule.new(Commodities::WHEAT, [1], -1))
#miner.add_production_rule(FixedProductionRule.new(Commodities::ORE, [1], 2))
#miner.add_production_rule(FixedProductionRule.new(Commodities::ORE, [1, 2], 2))
#miner.add_production_rule(FixedProductionRule.new(Commodities::TOOLS, [1, 2, 3], -1))
#
#miner.set_commodity_prefs(Commodities::WHEAT, 40, true, false)
#miner.set_commodity_prefs(Commodities::WOOD, 0, false, false)
#miner.set_commodity_prefs(Commodities::ORE, 140, false, true)
#miner.set_commodity_prefs(Commodities::METAL, 0, false, false)
#miner.set_commodity_prefs(Commodities::TOOLS, 5, true, false)
#
##Refiner AgentRole
#refiner = AgentRole.new('Refiner', Commodities.all)
#
#refiner.add_condition(1, HasCommodityCondition.new(Commodities::WHEAT))
#refiner.add_condition(2, HasCommodityCondition.new(Commodities::TOOLS))
#refiner.add_condition(3, ChanceCondition.new(0.1))
#
#refiner.add_variable(1, CommodityQuantityVariable.new(Commodities::ORE))
#refiner.add_variable(2, NegateVariable.new(CommodityQuantityVariable.new(Commodities::ORE)))
#
#refiner.add_production_rule(FixedProductionRule.new(Commodities::WHEAT, [1], -1))
#refiner.add_production_rule(VariableProductionRule.new(Commodities::METAL, [1, 2], 1))
#refiner.add_production_rule(VariableProductionRule.new(Commodities::ORE, [1, 2], 2))
#refiner.add_production_rule(FixedProductionRule.new(Commodities::TOOLS, [1, 2, 3], -1))
#
#refiner.set_commodity_prefs(Commodities::WHEAT, 40, true, false)
#refiner.set_commodity_prefs(Commodities::WOOD, 0, false, false)
#refiner.set_commodity_prefs(Commodities::ORE, 70, true, false)
#refiner.set_commodity_prefs(Commodities::METAL, 70, false, true)
#refiner.set_commodity_prefs(Commodities::TOOLS, 5, true, false)
#
##Woodcutter AgentRole
#woodcutter = AgentRole.new('Woodcutter', Commodities.all)
#
#woodcutter.add_condition(1, HasCommodityCondition.new(Commodities::WHEAT))
#woodcutter.add_condition(2, HasCommodityCondition.new(Commodities::TOOLS))
#woodcutter.add_condition(3, ChanceCondition.new(0.1))
#
#woodcutter.add_production_rule(FixedProductionRule.new(Commodities::WHEAT, [1], -1))
#woodcutter.add_production_rule(FixedProductionRule.new(Commodities::WOOD, [1], 1))
#woodcutter.add_production_rule(FixedProductionRule.new(Commodities::WOOD, [1, 2], 1))
#woodcutter.add_production_rule(FixedProductionRule.new(Commodities::TOOLS, [1, 2, 3], -1))
#
#woodcutter.set_commodity_prefs(Commodities::WHEAT, 40, true, false)
#woodcutter.set_commodity_prefs(Commodities::WOOD, 140, false, true)
#woodcutter.set_commodity_prefs(Commodities::ORE, 0, false, false)
#woodcutter.set_commodity_prefs(Commodities::METAL, 0, false, false)
#woodcutter.set_commodity_prefs(Commodities::TOOLS, 5, true, false)
#
##Blacksmith AgentRole
#blacksmith = AgentRole.new('Blacksmith', Commodities.all)
#
#blacksmith.add_condition(1, HasCommodityCondition.new(Commodities::WHEAT))
#
#blacksmith.add_variable(1, CommodityQuantityVariable.new(Commodities::METAL))
#blacksmith.add_variable(2, NegateVariable.new(CommodityQuantityVariable.new(Commodities::METAL)))
#
#blacksmith.add_production_rule(FixedProductionRule.new(Commodities::WHEAT, [1], -1))
#blacksmith.add_production_rule(VariableProductionRule.new(Commodities::TOOLS, [1], 1))
#blacksmith.add_production_rule(VariableProductionRule.new(Commodities::METAL, [1], 2))
#
#blacksmith.set_commodity_prefs(Commodities::WHEAT, 40, true, false)
#blacksmith.set_commodity_prefs(Commodities::WOOD, 0, false, false)
#blacksmith.set_commodity_prefs(Commodities::ORE, 0, false, false)
#blacksmith.set_commodity_prefs(Commodities::METAL, 70, true, false)
#blacksmith.set_commodity_prefs(Commodities::TOOLS, 70, false, true)

#MAIN
rounds = 100
num_agents = 1000

agents_json = ''
commodities_json = ''

File.open('Resources/Commodities.json', 'r'){|fileIO|
  commodities_json = fileIO.read
}

File.open('Resources/Agents.json', 'r'){|fileIO|
  agents_json = fileIO.read
}

DataParser.parse(commodities_json)
DataParser.parse(agents_json)

Inventory.max_stock = 200
market = Market.new(Commodities.all)
#spawner = AgentSpawner.new(market, [farmer, miner, refiner, woodcutter, blacksmith], 1000)
spawner = AgentSpawner.new(market, SimData.instance.agent_roles, 1000)
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

rounds.times{|n|
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
