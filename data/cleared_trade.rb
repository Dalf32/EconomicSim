# cleared_trade.rb
#
# Author::  Kyle Mullins

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
