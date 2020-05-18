# frozen_string_literal: true

# market.rb
#
# Author::  Kyle Mullins

require_relative '../data/trades/trades'
require_relative '../utilities/extensions'
require_relative '../utilities/tracked_array'
require_relative '../events/event_reactor'
require_relative '../events/events'

# Receives all Asks and Bids from Agents and resolves them into trades
class Market
  attr_reader :commodities, :purchase_history

  # Creates a new Market
  #
  # @param commodities [Array<Commodities>] List of all Commodities traded
  # @param trade_tracker [TradeTracker] Store of historical trade data
  def initialize(commodities, trade_tracker)
    @commodities = commodities
    @trade_tracker = trade_tracker

    @bids = Hash.new { |h, k| h[k] = [] }
    @asks = Hash.new { |h, k| h[k] = [] }
    @purchase_history = Hash.new { |h, k| h[k] = TrackedArray.new }
  end

  # Records an Ask for the given Commodity
  #
  # @param commodity [Commodity] The Commodity to be sold
  # @param ask [Ask] The Ask being posted
  def post_ask(commodity, ask)
    EventReactor.pub(AskPostedEvent.new(commodity, ask))
    @asks[commodity] << ask
  end

  # Records a Bid for the given Commodity
  #
  # @param commodity [Commodity] The Commodity to be bought
  # @param bid [Bid] The Bid being posted
  def post_bid(commodity, bid)
    EventReactor.pub(BidPostedEvent.new(commodity, bid))
    @bids[commodity] << bid
  end

  # The last successful sale price of a Commodity
  #
  # @param commodity [Commodity] The Commodity in question
  # @return [Numeric]
  def last_price_of(commodity)
    @trade_tracker.price_of(commodity)
  end

  # The average sale price of a Commodity
  #
  # @param commodity [Commodity] The Commodity in question
  # @return [Numeric]
  def mean_price_of(commodity)
    @purchase_history[commodity].map(&:avg).avg
  end

  # Resolves offers for all Commodities posted
  def resolve_all_offers
    EventReactor.pub(RoundChangeEvent.new)

    @commodities.each { |commodity| resolve_offers(commodity) }
  end

  private

  def resolve_offers(commodity)
    purchases = TrackedArray.new

    @bids[commodity].shuffle.sort! { |a, b| b.bid_price <=> a.bid_price }
    @asks[commodity].shuffle.sort! { |a, b| a.ask_price <=> b.ask_price }

    until @bids[commodity].empty? || @asks[commodity].empty?
      bid = @bids[commodity][0]
      ask = @asks[commodity][0]
      quantity_traded = [ask.amount_remaining, bid.amount_remaining].min
      clearing_price = Math.avg(ask.ask_price, bid.bid_price)

      if quantity_traded.positive?
        cleared_trade = ClearedTrade.new(bid.buyer, ask.seller, commodity,
                                         quantity_traded, clearing_price)
        EventReactor.pub(TradeClearedEvent.new(cleared_trade))

        purchases << clearing_price

        ask.sell(quantity_traded)
        bid.buy(quantity_traded)

        ask.seller.trade_results(commodity, quantity_traded, clearing_price)
        bid.buyer.trade_results(commodity, quantity_traded, clearing_price)
      end

      @asks[commodity].shift if ask.fulfilled?
      @bids[commodity].shift if bid.fulfilled?
    end

    unless @bids[commodity].empty?
      @bids[commodity].each do |bid|
        # bid.buyer.bid_results(commodity, 0, 0, false)
        bid.buyer.update_failed_trades
      end

      @bids[commodity].clear
    end

    unless @asks[commodity].empty?
      @asks[commodity].each do |ask|
        # ask.seller.ask_results(commodity, 0, 0, false)
        ask.seller.update_failed_trades
      end

      @asks[commodity].clear
    end

    @purchase_history[commodity] << purchases
  end
end
