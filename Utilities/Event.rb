#Event.rb

require 'Observer'

class Event
  include Observable

  def <<(handler)
    add_observer(handler)
  end

  def >>(handler)
    delete_observer(handler)
  end

  def fire(*args)
    changed
    notify_observers(*args)
  end
end
