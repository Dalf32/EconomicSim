# frozen_string_literal: true

# bid_posted_event.rb
#
# Author::  Kyle Mullins

# Triggered when a Bid is posted to the market
class BidPostedEvent
  attr_reader :commodity, :bid

  # Creates a new BidPostedEvent
  #
  # @param commodity [Commodity] The Commodity for which the bid was posted
  # @param bid [Bid] The Bid that was posted
  def initialize(commodity, bid)
    @commodity = commodity
    @bid = bid
  end

  # The type of event
  #
  # @return [Symbol]
  def event_type
    :bid_posted
  end
end
