# frozen_string_literal: true

# agent_role.rb
#
# Author::  Kyle Mullins

require_relative 'inventory'
require_relative 'economic_agent'

# Models the behavioral rules for a type of Agent
class AgentRole
  BUYS = 0x01
  SELLS = 0x02

  attr_reader :name

  # Creates a new AgentRole
  #
  # @param name [String] Name of the role
  # @param commodities [Array<Commodity>] List of all Commodities traded in the market
  def initialize(name, commodities)
    @name = name
    @inventory = Inventory.new(commodities)
    @conditions = {}
    @production_rules = []
    @trade_prefs = Hash.new { |hash, key| hash[key] = 0 }
  end

  # Creates a new Agent with this role
  #
  # @param market [Market] The Market at which this Agent will trade
  # @param starting_funds [Numeric] Amount of money the Agent will have
  # @return [EconomicAgent] New Agent with this role
  def new_agent(market, starting_funds)
    EconomicAgent.new(self, market, starting_funds, @inventory.clone)
  end

  # Adds a Condition to this role which will be evaluated during production
  #
  # @param condition [Condition] Condition to be added
  def add_condition(condition)
    @conditions[condition.id] = condition
  end

  # Configures how Agents of this role interact with the given Commodity
  #
  # @param commodity [Commodity] The Commodity being set up
  # @param ideal_stock [Numeric] Amount the Agent will attempt to maintain in stock
  # @param buys [Boolean] Whether the Agent will attempt to buy the Commodity
  # @param sells [Boolean] Whether the Agent will attempt to sell the Commodity
  def set_commodity_prefs(commodity, ideal_stock, buys, sells)
    @inventory.set_ideal_stock_of(commodity, ideal_stock)

    @trade_prefs[commodity] = (buys ? BUYS : 0) | (sells ? SELLS : 0)
  end

  # Adds a Production Rule to this role which will be evaluated based on some
  # Conditions to modify the Agent's inventory
  #
  # @param rule [ProductionRule] Rule to be added
  def add_production_rule(rule)
    @production_rules << rule
  end

  # Evaluates this role's Conditions and Production Rules for the given Agent
  #
  # @param agent [EconomicAgent] Agent for which to run the Production Rules
  def perform_production(agent)
    condition_vals = evaluate_conditions(agent)

    @production_rules.each { |rule| rule.produce(agent, condition_vals) }
  end

  # Whether the given Commodity is bought by this role
  #
  # @param commodity [Commodity] The Commodity of interest
  # @return [Boolean]
  def buys?(commodity)
    !(@trade_prefs[commodity] & BUYS).zero?
  end

  # Whether the given Commodity is sold by this role
  #
  # @param commodity [Commodity] The Commodity of interest
  # @return [Boolean]
  def sells?(commodity)
    !(@trade_prefs[commodity] & SELLS).zero?
  end

  # Returns the Commodities this role buys
  #
  # @return [Array<Commodity>] List of Commodities bought by Agents of this role
  def commodities_to_buy
    @trade_prefs.keys.select { |commodity| buys?(commodity) }
  end

  # Returns the Commodities this role sells
  #
  # @return [Array<Commodity>] List of Commodities sold by Agents of this role
  def commodities_to_sell
    @trade_prefs.keys.select { |commodity| sells?(commodity) }
  end

  private

  def evaluate_conditions(agent)
    @conditions.map { |id, cond| [id, cond.evaluate(agent)] }.to_h
  end
end
