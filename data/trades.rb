# trades.rb
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

class ClearedTrade
  attr_reader :buyer, :seller, :commodity, :quantity, :price

  def initialize(buyer, seller, commodity, quantity_traded, clearing_price)
    @buyer = buyer
    @seller = seller
    @commodity = commodity
    @quantity = quantity_traded
    @price = clearing_price
  end

  def total_cost
    @quantity * @price
  end
end
