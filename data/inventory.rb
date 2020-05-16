# frozen_string_literal: true

# inventory.rb
#
# Author::  Kyle Mullins

# Holds an Agent's stock of all Commodities
class Inventory

  # Creates a new Inventory
  #
  # @param commodities [Array<Commodity>] List of all Commodities that are traded
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

  # Copies this Inventory to a new Object
  #
  # @return [Inventory]
  def clone
    Inventory.new(@commodities.keys).tap do |inventory|
      @commodities.each_pair do |commodity, id|
        inventory.set_ideal_stock_of(commodity, @ideal_stock[id])
        inventory.set_stock_of(commodity, @stock[id])
      end
    end
  end

  # Sets the ideal stock of a Commodity for this Inventory's Agent
  #
  # @param commodity [Commodity] Commodity in question
  # @param ideal [Numeric] The ideal stock of the Commodity for this Agent
  def set_ideal_stock_of(commodity, ideal)
    id = commodity_id(commodity)
    @ideal_stock[id] = ideal
    @stock[id] = ideal
  end

  # The total amount of items in this Inventory
  #
  # @return [Numeric]
  def total_stock
    @stock.sum
  end

  # The amount of leftover space in this Inventory
  #
  # @return [Numeric]
  def empty_space
    max_stock - total_stock
  end

  # Whether or not there are any of the given Commodity in this Inventory
  #
  # @param commodity [Commodity] The Commodity in question
  # @return [Boolean]
  def stock_of?(commodity)
    stock_of(commodity).positive?
  end

  # The number of items of the given Commodity in this Inventory
  #
  # @param commodity [Commodity] The Commodity in question
  # @return [Numeric]
  def stock_of(commodity)
    @stock[commodity_id(commodity)]
  end

  # The Agent's ideal number of items of the given Commodity to have in the
  # Inventory
  #
  # @param commodity [Commodity] The Commodity in question
  # @return [Numeric]
  def ideal_stock_of(commodity)
    @ideal_stock[commodity_id(commodity)]
  end

  # Whether or not there are more items of the given Commodity than the ideal
  #
  # @param commodity [Commodity] The Commodity in question
  # @return [Boolean]
  def surplus_of?(commodity)
    surplus_of(commodity) != 0
  end

  # Whether or not there are fewer items of the given Commodity than the ideal
  #
  # @param commodity [Commodity] The Commodity in question
  # @return [Boolean]
  def shortage_of?(commodity)
    shortage_of(commodity) != 0
  end

  # The number of extra items of the given Commodity above the ideal
  #
  # @param commodity [Commodity] The Commodity in question
  # @return [Numeric] Number of surplus items or 0
  def surplus_of(commodity)
    amount = stock_of(commodity)
    ideal = ideal_stock_of(commodity)

    [amount - ideal, 0].max
  end

  # The number of items below the ideal of the given Commodity
  #
  # @param commodity [Commodity] The Commodity in question
  # @return [Numeric] Number of items short or 0
  def shortage_of(commodity)
    amount = stock_of(commodity)
    ideal = ideal_stock_of(commodity)

    [ideal - amount, 0].max
  end

  # Updates the current stock of the given Commodity by some amount
  #
  # @param commodity [Commodity] The Commodity in question
  # @param change [Numeric] The amount by which to change the stock
  def change_stock_of(commodity, change)
    @stock[commodity_id(commodity)] += change
  end

  # Sets the current stock of the given Commodity to some amount
  #
  # @param commodity [Commodity] The Commodity in question
  # @param stock [Numeric] The amount of items that should be in stock
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
