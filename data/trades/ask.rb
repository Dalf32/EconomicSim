# frozen_string_literal: true

# ask.rb
#
# Author::  Kyle Mullins

# Represents an attempt for an Agent to sell an amount of some Commodity
# at a given price
class Ask
  attr_reader :seller, :ask_price, :offered_amount, :sold_amount

  # Creates a new Ask
  #
  # @param seller [EconomicAgent] Agent selling the Commodity
  # @param price [Numeric] Price of each item
  # @param amount [Numeric] Amount of items for sale
  def initialize(seller, price, amount)
    @seller = seller
    @ask_price = price
    @offered_amount = amount
    @sold_amount = 0
  end

  # The amount that has not yet been sold
  #
  # @return [Numeric]
  def amount_remaining
    @offered_amount - @sold_amount
  end

  # Whether or not the full offered amount has been sold
  #
  # @return [Boolean]
  def fulfilled?
    amount_remaining.zero?
  end

  # Updates the sold amount to reflect the sale of the given amount
  #
  # @param amount [Numeric] Amount that was sold
  def sell(amount)
    @sold_amount += amount if amount_remaining >= amount
  end
end
