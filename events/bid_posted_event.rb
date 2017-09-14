# bid_posted_event.rb
#
# Author::  Kyle Mullins

class BidPostedEvent
  attr_reader :commodity, :bid

  def initialize(commodity, bid)
    @commodity = commodity
    @bid = bid
  end

  def event_type
    :bid_posted
  end
end
