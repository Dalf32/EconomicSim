# ask.rb
#
# Author::  Kyle Mullins

class Ask
  attr_reader :seller, :ask_price, :offered_amount, :sold_amount

  def initialize(seller, price, amount)
    @seller = seller
    @ask_price = price
    @offered_amount = amount
    @sold_amount = 0
  end

  def amount_remaining
    @offered_amount - @sold_amount
  end

  def fulfilled?
    amount_remaining.zero?
  end

  def sell(amount)
    @sold_amount += amount if amount_remaining >= amount
  end
end
