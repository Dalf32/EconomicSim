# inventory.rb
#
# Author::  Kyle Mullins

class Inventory
  def initialize(commodities)
    @commodities = {}
    @ideal_stock = []
    @stock = []
    @trade_prefs = []

    commodities.each_index do |id|
      @commodities[commodities[id]] = id
      @ideal_stock[id] = 0
      @stock[id] = 0
    end
  end

  def clone
    Inventory.new(@commodities.keys).tap do |inventory|
      @commodities.each_pair do |commodity, id|
        inventory.set_ideal_stock_of(commodity, @ideal_stock[id])
        inventory.set_stock_of(commodity, @stock[id])
      end
    end
  end

  def set_ideal_stock_of(commodity, ideal)
    id = commodity_id(commodity)
    @ideal_stock[id] = ideal
    @stock[id] = ideal
  end

  def total_stock
    @stock.sum
  end

  def empty_space
    self.max_stock - total_stock
  end

  def stock_of?(commodity)
    stock_of(commodity).positive?
  end

  def stock_of(commodity)
    @stock[commodity_id(commodity)]
  end

  def ideal_stock_of(commodity)
    @ideal_stock[commodity_id(commodity)]
  end

  def surplus_of?(commodity)
    surplus_of(commodity) != 0
  end

  def shortage_of?(commodity)
    shortage_of(commodity) != 0
  end

  def surplus_of(commodity)
    amount = stock_of(commodity)
    ideal = ideal_stock_of(commodity)

    [amount - ideal, 0].max
  end

  def shortage_of(commodity)
    amount = stock_of(commodity)
    ideal = ideal_stock_of(commodity)

    [ideal - amount, 0].max
  end

  def change_stock_of(commodity, change)
    @stock[commodity_id(commodity)] += change
  end

  def set_stock_of(commodity, stock)
    @stock[commodity_id(commodity)] = stock
  end

  def self.max_stock
    @max_stock
  end

  def self.max_stock=(max_stock)
    @max_stock = max_stock
  end

  private

  def commodity_id(commodity)
    unless commodity.is_a?(Commodity)
      commodity = @commodities.keys.find { |c| c.name == commodity }
    end

    @commodities[commodity]
  end
end
