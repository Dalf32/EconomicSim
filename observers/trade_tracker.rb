# frozen_string_literal: true

# trade_tracker.rb
#
# Author::  Kyle Mullins

require_relative '../utilities/tracked_array'
require_relative '../utilities/tracked_ring_buffer'
require_relative '../events/event_reactor'

# Stores historical data regarding Commodity prices and Agent profits
class TradeTracker
  attr_reader :history_window_size

  # Creates a new TradeTracker
  def initialize
    @last_id = 0
    @current_round = 0
    @history_window_size = 10

    @current_commodity_prices = Hash.new { |hash, key| hash[key] = TrackedArray.new }
    @commodity_prices = Hash.new { |hash, key| hash[key] = TrackedRingBuffer.new(@history_window_size) }

    @current_agent_profits = Hash.new { |hash, key| hash[key] = 0 }
    @agent_profits = Hash.new { |hash, key| hash[key] = TrackedRingBuffer.new(@history_window_size) }

    @cleared_trades = {}
    @trades_by_round = Hash.new { |hash, key| hash[key] = [] }
    @trades_by_commodity = Hash.new { |hash, key| hash[key] = [] }
    @trades_by_buyer_type = Hash.new { |hash, key| hash[key] = [] }
    @trades_by_seller_type = Hash.new { |hash, key| hash[key] = [] }
  end

  # Registers for the needed events with the reactor
  def register_events
    EventReactor.sub(:trade_cleared, &method(:trade_cleared))
    EventReactor.sub(:round_change, &method(:change_round))
  end

  # Average sale price of a Commodity
  #
  # @param commodity [Commodity] The Commodity in question
  # @return [Numeric] Average price of the Commodity over the last several rounds
  def price_of(commodity)
    @commodity_prices[commodity].avg
  end

  # Average profits of a type of Agent
  # @param agent_type [AgentRole] The type of Agent in question
  # @return [Numeric] Average profits of Agents of the role over the last
  # several rounds
  def profitability_of(agent_type)
    @agent_profits[agent_type].avg
  end

  # When a round of the simulation ends, updates based on the data tracked
  # during that round
  #
  # @param _event [RoundChangeEvent] Event fired when a round of the simulation
  # ends
  def change_round(_event)
    @current_round += 1

    @current_agent_profits.each_key do |agent_role|
      @agent_profits[agent_role] << @current_agent_profits[agent_role]
      @current_agent_profits[agent_role] = 0
    end

    @current_commodity_prices.each_key do |commodity|
      unless @current_commodity_prices[commodity].empty?
        @commodity_prices[commodity] << @current_commodity_prices[commodity]
        @current_commodity_prices[commodity] = TrackedArray.new
      end
    end
  end

  # Tracks data about a cleared trade
  #
  # @param event [TradeClearedEvent] Event fired when a trade is completed
  def trade_cleared(event)
    trade = event.cleared_trade
    id = next_id

    @cleared_trades[id] = trade
    @trades_by_round[@current_round] << id
    @trades_by_commodity[trade.commodity] << id
    @trades_by_buyer_type[trade.buyer.role] << id
    @trades_by_seller_type[trade.seller.role] << id

    @current_agent_profits[trade.buyer.role] -= trade.total_cost
    @current_agent_profits[trade.seller.role] += trade.total_cost

    @current_commodity_prices[trade.commodity] << trade.price
  end

  private

  def next_id
    @last_id += 1
  end
end
