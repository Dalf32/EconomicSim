# frozen_string_literal: true

# commodity_tracker.rb
#
# Author::  Kyle Mullins

require_relative '../utilities/tracked_array'
require_relative '../events/event_reactor'

# Tracks the supply, demand, and price of Commodities in the simulation and logs
# the data to CSV files
class CommodityTracker

  # Creates a new CommodityTracker
  #
  # @param commodities [Array<Commodity>] List of all Commodities in the system
  def initialize(commodities)
    @current_round = 0
    @commodities = commodities

    @supply = Hash.new { |hash, key| hash[key] = 0 }
    @demand = Hash.new { |hash, key| hash[key] = 0 }

    @all_prices = Hash.new { |hash, key| hash[key] = TrackedArray.new }
    @max_prices = Hash.new { |hash, key| hash[key] = 0 }
    @min_prices = Hash.new { |hash, key| hash[key] = 0 }

    @supply_file = File.new('logs/supply.csv', 'w')
    @demand_file = File.new('logs/demand.csv', 'w')
    @ratio_file = File.new('logs/supply_demand_ratio.csv', 'w')
    @mean_price_file = File.new('logs/mean_price.csv', 'w')
    @price_variance_file = File.new('logs/price_variance.csv', 'w')

    @all_files = [@supply_file, @demand_file, @ratio_file, @mean_price_file,
                  @price_variance_file]
  end

  # Registers for the needed events with the reactor
  def register_events
    EventReactor.sub(:trade_cleared, &method(:trade_cleared))
    EventReactor.sub(:round_change, &method(:change_round))
    EventReactor.sub(:ask_posted, &method(:ask_posted))
    EventReactor.sub(:bid_posted, &method(:bid_posted))
  end

  # When a round of the simulation ends, write out the data logged during that
  # round
  #
  # @param _event [RoundChangeEvent] The event fired when a round of the
  # simulation ends
  def change_round(_event)
    if @current_round.zero?
      header_str = 'Round'

      @commodities.each do |commodity|
        header_str += ",#{commodity.name}"
      end

      header_str += "\n"

      @all_files.each { |file| file << header_str }
    else
      @all_files.each { |file| file << @current_round.to_s }

      @commodities.each do |commodity|
        @ratio_file << ",#{@supply[commodity] / @demand[commodity].to_f}"

        @supply_file << ",#{@supply[commodity]}"
        @supply[commodity] = 0

        @demand_file << ",#{@demand[commodity]}"
        @demand[commodity] = 0

        @mean_price_file << ",#{@all_prices[commodity].avg}"
        @all_prices[commodity] = TrackedArray.new

        @price_variance_file << ",#{@max_prices[commodity] - @min_prices[commodity]}"
        @max_prices[commodity] = 0
        @min_prices[commodity] = 0
      end

      @all_files.each { |file| file << "\n" }
    end

    @current_round += 1
  end

  # Adds the amount of the Ask to the running supply total for that Commodity
  #
  # @param event [AskPostedEvent] Event fired when an Ask is posted
  def ask_posted(event)
    @supply[event.commodity] += event.ask.offered_amount
  end

  # Adds the amount of the Bid to the running demand total for that Commodity
  #
  # @param event [BidPostedEvent] Event fired when a Bid is posted
  def bid_posted(event)
    @demand[event.commodity] += event.bid.desired_amount
  end

  # Tracks the agreed-upon price of the Commodity traded
  #
  # @param event [TradeClearedEvent] Event fired when a trade is successful
  def trade_cleared(event)
    trade = event.cleared_trade
    @all_prices[trade.commodity] << trade.price
    @max_prices[trade.commodity] = trade.price if trade.price > @max_prices[trade.commodity]
    @min_prices[trade.commodity] = trade.price if trade.price < @min_prices[trade.commodity]
  end
end
