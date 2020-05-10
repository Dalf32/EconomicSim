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
    inventory = Inventory.new(@commodities.keys)

    @commodities.each_pair do |commodity, id|
      inventory.set_ideal_stock_of(commodity, @ideal_stock[id])
      inventory.set_stock_of(commodity, @stock[id])
    end

    inventory
  end

  def set_ideal_stock_of(commodity, ideal)
    id = @commodities[commodity]
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
    stock_of(commodity) != 0
  end

  def stock_of(commodity)
    @stock[@commodities[commodity]]
  end

  def ideal_stock_of(commodity)
    @ideal_stock[@commodities[commodity]]
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

    amount > ideal ? amount - ideal : 0
  end

  def shortage_of(commodity)
    amount = stock_of(commodity)
    ideal = ideal_stock_of(commodity)

    amount < ideal ? ideal - amount : 0
  end

  def change_stock_of(commodity, change)
    @stock[@commodities[commodity]] += change
  end

  def set_stock_of(commodity, stock)
    @stock[@commodities[commodity]] = stock
  end

  def self.max_stock
    @max_stock
  end

  def self.max_stock=(max_stock)
    @max_stock = max_stock
  end
end
