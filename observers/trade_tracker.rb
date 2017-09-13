#TradeTracker.rb

require 'singleton'

require_relative '../data/trades'
require_relative '../utilities/tracked_array'
require_relative '../utilities/tracked_ring_buffer'

class TradeTracker
  include Singleton
  
  attr_reader :history_window_size

  def initialize
    @last_id = 0
    @current_round = 0
    @history_window_size = 10

    @current_commodity_prices = Hash.new{|hash, key| hash[key] = TrackedArray.new}
    @commodity_prices = Hash.new{|hash, key| hash[key] = TrackedRingBuffer.new(@history_window_size)}

    @current_agent_profits = Hash.new{|hash, key| hash[key] = 0}
    @agent_profits = Hash.new{|hash, key| hash[key] = TrackedRingBuffer.new(@history_window_size)}

    @cleared_trades = Hash.new
    @trades_by_round = Hash.new{|hash, key| hash[key] = Array.new}
    @trades_by_commodity = Hash.new{|hash, key| hash[key] = Array.new}
    @trades_by_buyer_type = Hash.new{|hash, key| hash[key] = Array.new}
    @trades_by_seller_type = Hash.new{|hash, key| hash[key] = Array.new}
  end

  def price_of(commodity)
    @commodity_prices[commodity].avg
  end

  def profitability_of(agent_type)
    @agent_profits[agent_type].avg
  end

  def change_round
    @current_round += 1
    @trades_by_round[@current_round] = Array.new

    @current_agent_profits.each_key{|agent_role|
      unless @current_agent_profits[agent_role] == 0
        @agent_profits[agent_role]<<@current_agent_profits[agent_role]
        @current_agent_profits[agent_role] = 0
      end
    }

    @current_commodity_prices.each_key{|commodity|
      unless @current_commodity_prices[commodity].empty?
        @commodity_prices[commodity]<<@current_commodity_prices[commodity]
        @current_commodity_prices[commodity] = TrackedArray.new
      end
    }
  end

  def trade_cleared(buyer, seller, commodity, quantity_traded, clearing_price)
    trade = ClearedTrade.new(buyer.role, seller.role, commodity, quantity_traded, clearing_price)
    id = next_id

    @cleared_trades[id] = trade
    @trades_by_round[@current_round]<<id
    @trades_by_commodity[commodity]<<id
    @trades_by_buyer_type[buyer.role]<<id
    @trades_by_seller_type[seller.role]<<id

    @current_agent_profits[buyer.role] -= trade.total_cost
    @current_agent_profits[seller.role] += trade.total_cost

    @current_commodity_prices[commodity]<<clearing_price
  end

  def update(*args)
    if args.empty?
      change_round
    elsif args.length == 5
      trade_cleared(*args)
    end
  end

  private

  def next_id
    @last_id += 1
  end
end