# frozen_string_literal: true

# round_change_event.rb
#
# Author::  Kyle Mullins

# Triggered when the round of the simulation changes
class RoundChangeEvent

  # The type of event
  #
  # @return [Symbol]
  def event_type
    :round_change
  end
end
