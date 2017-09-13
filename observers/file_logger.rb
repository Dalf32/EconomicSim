#FileLogger.rb

require 'singleton'

class FileLogger
  include Singleton

  def initialize
    @current_round = 1

    log_directory = 'logs'
    @all_trades_log = File.new("#{log_directory}/all_trades.txt", 'w')
    @commodity_logs = Hash.new{|hash, key|
      hash[key] = File.new("#{log_directory}/#{key.name}.txt", 'w')
    }
  end

  def log_round_change
    round_change_str = "Round #{@current_round} start\n"

    @all_trades_log<<round_change_str
    @commodity_logs.each_value{|logfile|
      logfile<<round_change_str
    }

    @current_round += 1
  end

  def log_trade_cleared(buyer, seller, commodity, quantity_traded, clearing_price)
    @all_trades_log<<"#{quantity_traded} #{commodity.name} at #{clearing_price.round(2)}/unit\n"
    @all_trades_log<<"\tBuyer: #{buyer.role.name} (#{buyer.object_id})\n"
    @all_trades_log<<"\tSeller: #{seller.role.name} (#{seller.object_id})\n"

    @commodity_logs[commodity]<<"#{quantity_traded} at #{clearing_price.round(2)}/unit\n"
  end

  def update(*args)
    if args.empty?
      log_round_change
    elsif args.length == 5
      log_trade_cleared(*args)
    end
  end
end