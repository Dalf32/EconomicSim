# frozen_string_literal: true

# bid.rb
#
# Author::  Kyle Mullins

# Represents an attempt for an Agent to purchase an amount of some Commodity
# at a given price
class Bid
  attr_reader :buyer, :bid_price, :desired_amount, :bought_amount

  # Creates a new Bid
  #
  # @param buyer [EconomicAgent] Agent that wishes to purchase the Commodity
  # @param price [Numeric] Desired price of each item
  # @param amount [Numeric] Amount of items looking to be bought
  def initialize(buyer, price, amount)
    @buyer = buyer
    @bid_price = price
    @desired_amount = amount
    @bought_amount = 0
  end

  # The amount that has not yet been bought
  #
  # @return [Numeric]
  def amount_remaining
    @desired_amount - @bought_amount
  end

  # Whether or not the full requested amount has been bought
  #
  # @return [Boolean]
  def fulfilled?
    amount_remaining.zero?
  end

  # Updates the bought amount to reflect the purchase of the given amount
  #
  # @param amount [Numeric] Amount that was bought
  def buy(amount)
    @bought_amount += amount if amount_remaining >= amount
  end
end
