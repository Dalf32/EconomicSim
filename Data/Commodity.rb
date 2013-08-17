#Commodity.rb

class Commodity
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def eql?(other)
    @name.eql?(other.name)
  end

  def hash
    @name.hash
  end
end
