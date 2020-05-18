# frozen_string_literal: true

# file_logger.rb
#
# Author::  Kyle Mullins

require_relative '../events/event_reactor'

# Logs all trades to a file
class FileLogger

  # Creates a new FileLogger
  def initialize
    @current_round = 1

    log_directory = 'logs'
    @all_trades_log = File.new("#{log_directory}/all_trades.txt", 'w')
    @commodity_logs = Hash.new do |hash, key|
      hash[key] = File.new("#{log_directory}/#{key.name}.txt", 'w')
    end
  end

  # Registers for the needed events with the reactor
  def register_events
    EventReactor.sub(:trade_cleared, &method(:log_trade_cleared))
    EventReactor.sub(:round_change, &method(:log_round_change))
  end

  # Logs to the file that a round ended
  #
  # @param _event [RoundChangeEvent] Event fired when a round of the simulation
  # ends
  def log_round_change(_event)
    round_change_str = "Round #{@current_round} start\n"

    @all_trades_log << round_change_str
    @commodity_logs.each_value { |logfile| logfile << round_change_str }

    @current_round += 1
  end

  # Logs to the file that a trade has cleared in the market
  #
  # @param event [TradeClearedEvent] Event fired when a trade is completed
  def log_trade_cleared(event)
    trade = event.cleared_trade

    @all_trades_log << "#{trade.quantity} #{trade.commodity.name} at #{trade.price.round(2)}/unit\n"
    @all_trades_log << "\tBuyer: #{trade.buyer.role.name} (#{trade.buyer.object_id})\n"
    @all_trades_log << "\tSeller: #{trade.seller.role.name} (#{trade.seller.object_id})\n"

    @commodity_logs[trade.commodity] << "#{trade.quantity} at #{trade.price.round(2)}/unit\n"
  end
end
