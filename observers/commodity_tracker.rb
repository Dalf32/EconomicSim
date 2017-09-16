# commodity_tracker.rb
#
# Author::  Kyle Mullins

require_relative '../utilities/tracked_array'
require_relative '../events/event_reactor'

class CommodityTracker
  def initialize
    @current_round = 0
    @commodities = nil

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

    EventReactor.instance.subscribe(:trade_cleared, &method(:trade_cleared))
    EventReactor.instance.subscribe(:round_change, &method(:change_round))
    EventReactor.instance.subscribe(:ask_posted, &method(:ask_posted))
    EventReactor.instance.subscribe(:bid_posted, &method(:bid_posted))
  end

  def set_commodities(commodities)
    @commodities = commodities

    @commodities.each do |commodity|
      @supply[commodity] = 0
      @demand[commodity] = 0
    end
  end

  def change_round(_event)
    if @current_round.zero?
      header_str = 'Round'

      @commodities.each do |commodity|
        header_str << ",#{commodity.name}"
      end

      header_str << "\n"

      @all_files.each { |file| file << header_str }
    else
      @all_files.each { |file| file << @current_round.to_s }

      @commodities.each do |commodity|
        @ratio_file << ",#{@supply[commodity].to_f / @demand[commodity].to_f}"

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

  def ask_posted(event)
    @supply[event.commodity] += event.ask.offered_amount
  end

  def bid_posted(event)
    @demand[event.commodity] += event.bid.desired_amount
  end

  def trade_cleared(event)
    trade = event.cleared_trade
    @all_prices[trade.commodity] << trade.price
    @max_prices[trade.commodity] = trade.price unless @max_prices[trade.commodity] >= trade.price
    @min_prices[trade.commodity] = trade.price unless @min_prices[trade.commodity] <= trade.price
  end

  def update(*args)
    if args.empty?
      change_round
    elsif args.length == 2
      if args[1].is_a?(Ask)
        ask_posted(*args)
      elsif args[1].is_a?(Bid)
        bid_posted(*args)
      end
    elsif args.length == 5
      trade_cleared(*args)
    end
  end
end
