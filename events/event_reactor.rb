# event_reactor.rb
#
# Author::  Kyle Mullins

require 'singleton'

class EventReactor
  include Singleton

  def subscribe(event_type, &block)
    @subscriptions[event_type] << block
  end

  def publish(event)
    @queue_mutex.synchronize do
      @event_queue << event
    end
  end

  def stop
    @should_dispatch = false
  end

  private

  TICK_INTERVAL = 0.1

  def initialize
    @should_dispatch = true
    @event_queue = []
    @subscriptions = Hash.new { |hash, event| hash[event] = [] }
    @event_dispatch = Thread.new { dispatch_events }
    @queue_mutex = Mutex.new
  end

  def dispatch_events
    while @should_dispatch
      sleep(TICK_INTERVAL)

      @queue_mutex.synchronize do
        @event_queue.delete_if do |event|
          @subscriptions[event.event_type].each do |block|
            begin
              block.call(event)
            rescue StandardError => err
              $stderr.puts "#{err.class}: #{err.message}\n\t#{event.backtrace.join("\n\t")}"
              $stderr.flush
            end
          end

          @subscriptions[event.event_type].any?
        end
      end
    end
  end
end
