# frozen_string_literal: true

# condition.rb
#
# Author::  Kyle Mullins

# Defines a predicate to be evaluated against an Agent
class Condition
  attr_reader :id

  # Builds a Condition from the data in the hash
  #
  # @param condition_hash [Hash] Hash holding the specification of the Condition
  # @return [Condition] Newly-constructed Condition
  def self.from_hash(condition_hash)
    id = condition_hash['ID']
    function_name = condition_hash['Function'].to_sym
    function = ConditionFunctions.instance_method(function_name)
    parameters = condition_hash['Parameters']

    Condition.new(id, function, parameters)
  end

  # Creates a new Condition
  #
  # @param id [Object] Unique ID of the Condition
  # @param function [UnboundMethod] Function to be run against the Agent
  # @param parameters [Array] List of parameters to be passed to the function
  def initialize(id, function, parameters)
    @id = id
    @function = function
    @parameters = parameters
  end

  # Binds the function to the given Agent and executes it, passing in the list
  # of parameters
  #
  # @param agent [EconomicAgent] The Agent against which to execute the function
  # @return [Boolean] The result of the predicate function
  def evaluate(agent)
    @function.bind(agent).call(*@parameters)
  end
end
