# frozen_string_literal: true

# production_rule.rb
#
# Author::  Kyle Mullins

# Defines a method that alters an Agent's inventory under some Conditions
class ProductionRule

  # Builds a ProductionRule from the data in the hash
  #
  # @param rule_hash [Hash] Hash holding the specification of the ProductionRule
  # @return [ProductionRule] Newly-construction ProductionRule
  def self.from_hash(rule_hash)
    function_name = rule_hash['Function'].to_sym
    function = ProductionFunctions.instance_method(function_name)
    parameters = rule_hash['Parameters']
    condition_ids = rule_hash['Conditions']

    ProductionRule.new(function, parameters, condition_ids)
  end

  # Creates a new ProductionRule
  #
  # @param function [UnboundMethod] Method to be run against the Agent
  # @param parameters [Array] List of parameters to be passed to the method
  # @param condition_ids [Array] List of IDs of Conditions on the Agent which
  # must be satisfied in order for the rule to be run
  def initialize(function, parameters, condition_ids)
    @function = function
    @parameters = parameters
    @condition_ids = condition_ids
  end

  # Checks that all Conditions required by this rule have been met
  #
  # @param condition_vals [Hash] Mapping of all Condition IDs to their result
  # @return [Boolean] Whether all required Condition values are truthy
  def should_produce?(condition_vals)
    @condition_ids.all? { |id| condition_vals[id] }
  end

  # Binds the method to the given Agent and executes it, passing in the list of
  # parameters, but only if all Conditions for the rule have been satisfied
  #
  # @param agent [EconomicAgent] The Agent against which to execute the method
  # @param condition_vals [Hash] Mapping of all Condition IDs to their result
  def produce(agent, condition_vals)
    return unless should_produce?(condition_vals)

    @function.bind(agent).call(*@parameters)
  end
end
