# trade_cleared_event.rb
#
# Author::  Kyle Mullins

class TradeClearedEvent
  attr_reader :cleared_trade

  def initialize(cleared_trade)
    @cleared_trade = cleared_trade
  end

  def event_type
    :trade_cleared
  end
end
