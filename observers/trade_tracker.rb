# trade_tracker.rb
#
# Author::  Kyle Mullins

require_relative '../utilities/tracked_array'
require_relative '../utilities/tracked_ring_buffer'
require_relative '../events/event_reactor'

class TradeTracker
  attr_reader :history_window_size

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

  def register_events
    EventReactor::sub(:trade_cleared, &method(:trade_cleared))
    EventReactor::sub(:round_change, &method(:change_round))
  end

  def price_of(commodity)
    @commodity_prices[commodity].avg
  end

  def profitability_of(agent_type)
    @agent_profits[agent_type].avg
  end

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