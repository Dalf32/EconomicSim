# market.rb
#
# Author::  Kyle Mullins

require_relative '../data/trades/trades'
require_relative '../utilities/extensions'
require_relative '../utilities/tracked_array'
require_relative '../events/event_reactor'
require_relative '../events/events'

class Market
  attr_reader :commodities, :purchase_history

  def initialize(commodities, trade_tracker)
    @commodities = commodities
    @trade_tracker = trade_tracker

    @bids = {}
    @asks = {}
    @purchase_history = {}

    @commodities.each do |commodity|
      @asks[commodity] = []
      @bids[commodity] = []
      @purchase_history[commodity] = TrackedArray.new
    end
  end

  def post_ask(commodity, ask)
    EventReactor.instance.publish(AskPostedEvent.new(commodity, ask))
    @asks[commodity] << ask
  end

  def post_bid(commodity, bid)
    EventReactor.instance.publish(BidPostedEvent.new(commodity, bid))
    @bids[commodity] << bid
  end

  def last_price_of(commodity)
    @trade_tracker.price_of(commodity)
  end

  def mean_price_of(commodity)
    round_avgs = []

    @purchase_history[commodity].map { |round_history| round_avgs << round_history.avg }

    round_avgs.avg
  end

  def resolve_all_offers
    EventReactor.instance.publish(RoundChangeEvent.new)

    @commodities.each { |commodity| resolve_offers(commodity) }
  end

  def resolve_offers(commodity)
    purchases = TrackedArray.new

    @bids[commodity].shuffle.sort! { |a, b| b.bid_price <=> a.bid_price }
    @asks[commodity].shuffle.sort! { |a, b| a.ask_price <=> b.ask_price }

    until @bids[commodity].empty? || @asks[commodity].empty?
      bid = @bids[commodity][0]
      ask = @asks[commodity][0]
      quantity_traded = Math.min(ask.amount_remaining, bid.amount_remaining)
      clearing_price = Math.avg(ask.ask_price, bid.bid_price)

      if quantity_traded > 0
        cleared_trade = ClearedTrade.new(bid.buyer, ask.seller, commodity,
                                         quantity_traded, clearing_price)
        EventReactor.instance.publish(TradeClearedEvent.new(cleared_trade))

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