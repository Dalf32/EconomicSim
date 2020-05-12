# condition.rb
#
# Author::  Kyle Mullins

class Condition
  attr_reader :id

  def self.from_hash(condition_hash)
    id = condition_hash['ID']
    function_name = condition_hash['Function'].to_sym
    function = ConditionFunctions.instance_method(function_name)
    parameters = condition_hash['Parameters']

    Condition.new(id, function, parameters)
  end

  def initialize(id, function, parameters)
    @id = id
    @function = function
    @parameters = parameters
  end

  def evaluate(agent)
    @function.bind(agent).call(*@parameters)
  end
end
