# ask_posted_event.rb
#
# Author::  Kyle Mullins

class AskPostedEvent
  attr_reader :commodity, :ask

  def initialize(commodity, ask)
    @commodity = commodity
    @ask = ask
  end

  def event_type
    :ask_posted
  end
end
