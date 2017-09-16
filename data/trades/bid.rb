# bid.rb
#
# Author::  Kyle Mullins

class Bid
  attr_reader :buyer, :bid_price, :desired_amount, :bought_amount

  def initialize(buyer, price, amount)
    @buyer = buyer
    @bid_price = price
    @desired_amount = amount
    @bought_amount = 0
  end

  def amount_remaining
    @desired_amount - @bought_amount
  end

  def fulfilled?
    amount_remaining.zero?
  end

  def buy(amount)
    @bought_amount += amount if amount_remaining >= amount
  end
end
