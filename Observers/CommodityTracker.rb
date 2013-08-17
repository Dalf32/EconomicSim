#CommodityTracker.rb

require 'singleton'

class CommodityTracker
  include Singleton

  def initialize
    @current_round = 0
    @commodities = nil

    @supply = Hash.new{|hash, key| hash[key] = 0}
    @demand = Hash.new{|hash, key| hash[key] = 0}

    @all_prices = Hash.new{|hash, key| hash[key] = TrackedArray.new}
    @max_prices = Hash.new{|hash, key| hash[key] = 0}
    @min_prices = Hash.new{|hash, key| hash[key] = 0}

    @supply_file = File.new('logs/supply.csv', 'w')
    @demand_file = File.new('logs/demand.csv', 'w')
    @ratio_file = File.new('logs/supply_demand_ratio.csv', 'w')
    @mean_price_file = File.new('logs/mean_price.csv', 'w')
    @price_variance_file = File.new('logs/price_variance.csv', 'w')

    @all_files = [@supply_file, @demand_file, @ratio_file, @mean_price_file,
        @price_variance_file]
  end

  def set_commodities(commodities)
    @commodities = commodities

    @commodities.each{|commodity|
      @supply[commodity] = 0
      @demand[commodity] = 0
    }
  end

  def change_round
    if @current_round == 0
      header_str = 'Round'

      @commodities.each{|commodity|
        header_str<<",#{commodity.name}"
      }

      header_str<<"\n"

      @all_files.each{|file|
        file<<header_str
      }
    else
      @all_files.each{|file|
        file<<@current_round.to_s
      }

      @commodities.each{|commodity|
        @ratio_file<<",#{@supply[commodity].to_f / @demand[commodity].to_f}"

        @supply_file<<",#{@supply[commodity]}"
        @supply[commodity] = 0

        @demand_file<<",#{@demand[commodity]}"
        @demand[commodity] = 0

        @mean_price_file<<",#{@all_prices[commodity].avg}"
        @all_prices[commodity] = TrackedArray.new

        @price_variance_file<<",#{@max_prices[commodity] - @min_prices[commodity]}"
        @max_prices[commodity] = 0
        @min_prices[commodity] = 0
      }

      @all_files.each{|file|
        file<<"\n"
      }
    end

    @current_round += 1
  end

  def ask_posted(commodity, ask)
    @supply[commodity] += ask.offered_amount
  end

  def bid_posted(commodity, bid)
    @demand[commodity] += bid.desired_amount
  end

  def trade_cleared(_buyer, _seller, commodity, _quantity_traded, clearing_price)
    @all_prices[commodity]<<clearing_price
    @max_prices[commodity] = clearing_price unless @max_prices[commodity] >= clearing_price
    @min_prices[commodity] = clearing_price unless @min_prices[commodity] <= clearing_price
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