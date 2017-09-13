#Market

require_relative '../data/trades'
require_relative '../utilities/extensions'
require_relative '../utilities/tracked_array'
require_relative '../utilities/event'

class Market
  attr_reader :commodities, :purchase_history
  attr_reader :trade_cleared_event, :round_change_event, :ask_posted_event, :bid_posted_event

  def initialize(commodities)
    @commodities = commodities
    @bids = Hash.new
    @asks = Hash.new
    @purchase_history = Hash.new

    @commodities.each{|commodity|
      @asks[commodity] = Array.new
      @bids[commodity] = Array.new
      @purchase_history[commodity] = TrackedArray.new
    }

    @trade_cleared_event = Event.new
    @round_change_event = Event.new
    @ask_posted_event = Event.new
    @bid_posted_event = Event.new
  end

  def post_ask(commodity, ask)
    @ask_posted_event.fire(commodity, ask)
    @asks[commodity]<<ask
  end

  def post_bid(commodity, bid)
    @bid_posted_event.fire(commodity, bid)
    @bids[commodity]<<bid
  end

  def last_price_of(commodity)
    TradeTracker.instance.price_of(commodity)
  end

  def mean_price_of(commodity)
    round_avgs = Array.new

    @purchase_history[commodity].map{|round_history|
      round_avgs<<round_history.avg
    }

    round_avgs.avg
  end

  def resolve_all_offers
    @round_change_event.fire

    @commodities.each{|commodity|
      resolve_offers(commodity)
    }
  end

  def resolve_offers(commodity)
    purchases = TrackedArray.new

    @bids[commodity].shuffle.sort!{|a, b| b.bid_price <=> a.bid_price}
    @asks[commodity].shuffle.sort!{|a, b| a.ask_price <=> b.ask_price}

    until @bids[commodity].empty? || @asks[commodity].empty?
      bid = @bids[commodity][0]
      ask = @asks[commodity][0]
      quantity_traded = Math.min(ask.amount_remaining, bid.amount_remaining)
      clearing_price = Math.avg(ask.ask_price, bid.bid_price)

      if quantity_traded > 0
        @trade_cleared_event.fire(bid.buyer, ask.seller, commodity, quantity_traded, clearing_price)
        purchases<<clearing_price

        ask.sell(quantity_traded)
        bid.buy(quantity_traded)

        ask.seller.trade_results(commodity, quantity_traded, clearing_price)
        bid.buyer.trade_results(commodity, quantity_traded, clearing_price)
      end

      if ask.fulfilled?
        @asks[commodity].shift
      end

      if bid.fulfilled?
        @bids[commodity].shift
      end
    end

    unless @bids[commodity].empty?
      @bids[commodity].each{|bid|
        #bid.buyer.bid_results(commodity, 0, 0, false)
        bid.buyer.update_failed_trades
      }

      @bids[commodity].clear
    end

    unless @asks[commodity].empty?
      @asks[commodity].each{|ask|
        #ask.seller.ask_results(commodity, 0, 0, false)
        ask.seller.update_failed_trades
      }

      @asks[commodity].clear
    end

    @purchase_history[commodity]<<purchases
  end
end