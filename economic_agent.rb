# economic_agent.rb
#
# Author::  Kyle Mullins

require_relative 'utilities/extensions'
require_relative 'data/price_belief'
require_relative 'data/inventory'

class EconomicAgent
  attr_reader :role, :market, :funds, :inventory

  def initialize(role, market, starting_funds, starting_inv)
    @role = role
    @market = market
    @funds = starting_funds
    @inventory = starting_inv

    @beliefs = Hash.new { |hash, key| hash[key] = PriceBelief.new(15.0, 35.0) }
    @observed_prices = Hash.new { |hash, key| hash[key] = TrackedArray.new }
    @outstanding_asks = Hash.new { |hash, key| hash[key] = nil }
    @outstanding_bids = Hash.new { |hash, key| hash[key] = nil }
  end

  def perform_production
    @role.perform_production(self)
  end

  def trade_results(commodity, amount, price)
    @observed_prices[commodity] << price

    belief = @beliefs[commodity]
    believed_mean = belief.mean
    historical_mean = @market.last_price_of(commodity)
    delta_to_mean = historical_mean - believed_mean
    significant_margin = price * 0.25
    stock_ratio = @inventory.stock_of(commodity) / @inventory.ideal_stock_of(commodity)

    if delta_to_mean.abs > significant_margin
      @beliefs[commodity].translate(delta_to_mean / 2)
    end

    # This assumes that no agent will ever be both buying and selling the same commodity in the same round
    if !@outstanding_asks[commodity].nil?
      ask = @outstanding_asks[commodity]

      if ask.sold_amount > (ask.offered_amount / 2)
        # > 50% sold
        belief.narrow(belief.max * 0.1)
      elsif stock_ratio > 0.75
        # > 75% ideal inventory
        belief.translate(delta_to_mean)
      else
        belief.translate(belief.max * 0.1)
      end

      amount = -amount
      @outstanding_asks[commodity] = nil if ask.fulfilled?
    elsif !@outstanding_bids[commodity].nil?
      bid = @outstanding_bids[commodity]

      if bid.bought_amount > (bid.desired_amount / 2)
        # > 50% bought
        belief.narrow(belief.max * 0.1)
      elsif stock_ratio < 0.25
        # < 25% ideal inventory
        belief.translate(delta_to_mean)
      else
        belief.translate(belief.max * 0.1)
      end

      @outstanding_bids[commodity] = nil if bid.fulfilled?
    end

    @inventory.change_stock_of(commodity, amount)
    @funds -= amount * price
  end

  def update_failed_trades
    @market.commodities.each do |commodity|
      if !@outstanding_asks[commodity].nil? && !@outstanding_asks[commodity].fulfilled?
        delta_to_mean = @outstanding_asks[commodity].ask_price - @market.last_price_of(commodity)
        @beliefs[commodity].translate(delta_to_mean * 0.1)
        @outstanding_asks[commodity] = nil
      elsif !@outstanding_bids[commodity].nil? && !@outstanding_bids[commodity].fulfilled?
        @beliefs[commodity].expand(@beliefs[commodity].mean * 0.1)
        @outstanding_bids[commodity] = nil
      end
    end
  end

  def generate_asks
    @role.commodities_to_sell.each do |commodity|
      if @inventory.surplus_of?(commodity)
        create_ask(commodity, @inventory.surplus_of(commodity))
      elsif @inventory.stock_of?(commodity)
        # Do we need to do anything here?
      end
    end
  end

  def generate_bids
    @role.commodities_to_buy.each do |commodity|
      if @inventory.shortage_of?(commodity)
        create_bid(commodity, @inventory.shortage_of(commodity))
      end
    end
  end

  private

  def create_bid(commodity, upper_limit)
    bid_price = @beliefs[commodity].choose_price
    proposed_amount = determine_bid_amount(commodity)
    desired_amount = Math.min(proposed_amount, upper_limit)

    bid = Bid.new(self, bid_price, desired_amount)

    @market.post_bid(commodity, bid)
    @outstanding_bids[commodity] = bid
  end

  def create_ask(commodity, lower_limit)
    if @inventory.stock_of?(commodity)
      ask_price = @beliefs[commodity].choose_price
      proposed_amount = determine_ask_amount(commodity)
      offer_amount = Math.max(proposed_amount, lower_limit)
      # offer_amount = Math.min(offer_amount, @inventory.stock_of(commodity))

      ask = Ask.new(self, ask_price, offer_amount)

      @market.post_ask(commodity, ask)
      @outstanding_asks[commodity] = ask
    end
  end

  def determine_ask_amount(commodity)
    price_belief = @beliefs[commodity]
    last_price = market.mean_price_of(commodity)

    last_price = price_belief.mean if last_price.nil?

    favorability = (last_price - price_belief.min) / price_belief.span.to_f
    ask_amt = favorability * @inventory.stock_of(commodity)
    Math.max(ask_amt.to_i, 1)
  end

  def determine_bid_amount(commodity)
    price_belief = @beliefs[commodity]
    last_price = market.mean_price_of(commodity)

    last_price = price_belief.mean if last_price.nil?

    favorability = (last_price - price_belief.min) / price_belief.span.to_f
    # bid_amt = (price_belief.max - favorability) * (@inventory_limit - @inventory[commodity])
    bid_amt = favorability * @inventory.shortage_of(commodity)
    raise 'NAN!' if bid_amt.nan?
    Math.max(bid_amt.to_i, 1)
  end
end