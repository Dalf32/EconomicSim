# extensions.rb
#
# Author::  Kyle Mullins

class Array
  def avg
    sum / size.to_f unless size.zero?
  end
end

module Math
  def self.avg(*vals)
    vals.sum / vals.count.to_f
  end
end
