# frozen_string_literal: true

# commodity.rb
#
# Author::  Kyle Mullins

# Represents an item that can be produced, consumed, bought, and sold
class Commodity
  attr_reader :name

  # Creates a new Commodity
  #
  # @param name [String] Name of the Commodity
  def initialize(name)
    @name = name
  end

  # Compares Commodities by name
  def eql?(other)
    @name.eql?(other.name)
  end

  # Hashes by name
  def hash
    @name.hash
  end
end
