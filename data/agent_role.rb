# agent_role.rb
#
# Author::  Kyle Mullins

require_relative 'inventory'
require_relative 'economic_agent'

class AgentRole
  BUYS = 0x01
  SELLS = 0x02

  attr_reader :name

  def initialize(name, commodities)
    @name = name
    @inventory = Inventory.new(commodities)
    @conditions = {}
    @production_rules = []
    @trade_prefs = Hash.new { |hash, key| hash[key] = 0 }
  end

  def new_agent(market, starting_funds)
    EconomicAgent.new(self, market, starting_funds, @inventory.clone)
  end

  def add_condition(condition)
    @conditions[condition.id] = condition
  end

  def set_commodity_prefs(commodity, ideal_stock, buys, sells)
    @inventory.set_ideal_stock_of(commodity, ideal_stock)

    @trade_prefs[commodity] = (buys ? BUYS : 0) | (sells ? SELLS : 0)
  end

  def add_production_rule(rule)
    @production_rules << rule
  end

  def perform_production(agent)
    condition_vals = evaluate_conditions(agent)

    @production_rules.each { |rule| rule.produce(agent, condition_vals) }
  end

  def buys?(commodity)
    !(@trade_prefs[commodity] & BUYS).zero?
  end

  def sells?(commodity)
    !(@trade_prefs[commodity] & SELLS).zero?
  end

  def commodities_to_buy
    @trade_prefs.keys.select { |commodity| buys?(commodity) }
  end

  def commodities_to_sell
    @trade_prefs.keys.select { |commodity| sells?(commodity) }
  end

  def evaluate_condition(agent, id)
    @conditions[id].evaluate(agent)
  end

  private

  def evaluate_conditions(agent)
    @conditions.map { |id, cond| [id, cond.evaluate(agent)] }.to_h
  end
end
