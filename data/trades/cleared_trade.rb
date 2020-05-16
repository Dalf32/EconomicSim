# frozen_string_literal: true

# cleared_trade.rb
#
# Author::  Kyle Mullins

# Represents a successful transaction between two Agents
class ClearedTrade
  attr_reader :buyer, :seller, :commodity, :quantity, :price

  # Creates a new ClearedTrade
  #
  # @param buyer [EconomicAgent] Agent that purchased the Commodity
  # @param seller [EconomicAgent] Agent that sold the Commodity
  # @param commodity [Commodity] The item that was sold
  # @param quantity_traded [Numeric] The amount that was sold
  # @param clearing_price [Numeric] The price per item sold
  def initialize(buyer, seller, commodity, quantity_traded, clearing_price)
    @buyer = buyer
    @seller = seller
    @commodity = commodity
    @quantity = quantity_traded
    @price = clearing_price
  end

  # The total amount of money exchanged
  #
  # @return [Numeric] Total cost of the transaction
  def total_cost
    @quantity * @price
  end
end
