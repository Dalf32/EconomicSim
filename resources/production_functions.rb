# ProductionFunctions
#
# AUTHOR::  Kyle Mullins

module ProductionFunctions
  def produce_amount(commodity, amount)
    inventory.change_stock_of(commodity, amount)
  end

  def consume_amount(commodity, amount)
    inventory.change_stock_of(commodity, -amount)
  end

  def convert_commodity(source_commodity, dest_commodity)
    source_amt = inventory.stock_of(source_commodity)

    inventory.set_stock_of(source_commodity, 0)
    inventory.change_stock_of(dest_commodity, source_amt)
  end
end