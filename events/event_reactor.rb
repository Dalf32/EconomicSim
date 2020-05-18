# frozen_string_literal: true

# event_reactor.rb
#
# Author::  Kyle Mullins

require 'singleton'

# Singleton to dispatch published events to subscribers of those events
class EventReactor
  include Singleton

  attr_accessor :is_synchronous

  # See #subscribe
  def self.sub(event_type, &block)
    instance.subscribe(event_type, &block)
  end

  # See #publish
  def self.pub(event)
    instance.publish(event)
  end

  # Registers the given code block to be run whenever an event of the given
  # type is received
  #
  # @param event_type [Symbol] The type of event being subscribed to
  # @param block [Proc] Callable to be run when the event is received
  def subscribe(event_type, &block)
    @subscriptions[event_type] << block
  end

  # Puts the event into queue to be dispatched to subscribers
  #
  # @param event [Object, #event_type] Event object to be dispatched
  def publish(event)
    if @is_synchronous
      dispatch_event(event)
      return
    end

    @queue_mutex.synchronize do
      @event_queue << event
    end
  end

  # Stops the event dispatch loop
  def stop
    @should_dispatch = false
  end

  private

  TICK_INTERVAL = 0.1

  def initialize
    @should_dispatch = true
    @event_queue = []
    @subscriptions = Hash.new { |hash, event| hash[event] = [] }
    @event_dispatch = Thread.new { dispatch_events_loop }
    @queue_mutex = Mutex.new
    @is_synchronous = false
  end

  def dispatch_events_loop
    while @should_dispatch
      sleep(TICK_INTERVAL)

      @queue_mutex.synchronize do
        @event_queue.delete_if do |event|
          dispatch_event(event)

          @subscriptions[event.event_type].any?
        end
      end
    end
  end

  def dispatch_event(event)
    @subscriptions[event.event_type].each do |block|
      begin
        block.call(event)
      rescue StandardError => e
        warn "#{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
      end
    end
  end
end
