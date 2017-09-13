# event.rb
#
# Author::  Kyle Mullins

require 'Observer'

class Event
  include Observable

  def <<(handler)
    add_observer(handler)
  end

  def >>(other)
    delete_observer(other)
  end

  def fire(*args)
    changed
    notify_observers(*args)
  end
end
