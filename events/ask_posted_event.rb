# frozen_string_literal: true

# ask_posted_event.rb
#
# Author::  Kyle Mullins

# Triggered when an Ask is posted to the market
class AskPostedEvent
  attr_reader :commodity, :ask

  # Creates a new AskPostedEvent
  #
  # @param commodity [Commodity] The Commodity for which the Ask was posted
  # @param ask [Ask] The Ask that was posted
  def initialize(commodity, ask)
    @commodity = commodity
    @ask = ask
  end

  # The type of event
  #
  # @return [Symbol]
  def event_type
    :ask_posted
  end
end
