#Extensions.rb

class Array
  def sum
    sum = 0

    map{|x| sum += x}

    sum
  end

  def avg
    unless size == 0
      sum / size
    end
  end
end

module Math
  def self.avg(a, b)
    (a + b) / 2.0
  end

  def self.min(a, b)
    a <= b ? a : b
  end

  def self.max(a, b)
    a >= b ? a : b
  end
end
