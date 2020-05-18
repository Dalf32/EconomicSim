# frozen_string_literal: true

# trade_cleared_event.rb
#
# Author::  Kyle Mullins

# Triggered when a trade is completed successfully in the market
class TradeClearedEvent
  attr_reader :cleared_trade

  # Creates a new TradeClearedEvent
  #
  # @param cleared_trade [ClearedTrade] The trade that was completed
  def initialize(cleared_trade)
    @cleared_trade = cleared_trade
  end

  # The type of event
  #
  # @return [Symbol]
  def event_type
    :trade_cleared
  end
end
