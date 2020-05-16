# frozen_string_literal: true

# sim_data_builder.rb
#
# Author::  Kyle Mullins

require 'json'

require_relative 'sim_data'
require_relative 'commodity'
require_relative 'agent_role_builder'

# Builds the SimData
class SimDataBuilder

  # Builds the SimData from a specification file (JSON)
  #
  # @param params_file [String] Path to the simulation data specification file
  # @return [SimData] Newly-constructed SimData
  def self.from_file(params_file)
    params_hash = SimDataBuilder.read_file(params_file)
    resource_hashes = params_hash['Resources'].map do |resource_file|
      SimDataBuilder.read_file(resource_file)
    end
    scripts = params_hash['Scripts']

    SimDataBuilder.from_hash(params_hash, resource_hashes, scripts)
  end

  # Builds the SimData from specification hashes
  #
  # @param params_hash [Hash] Hash holding all of the basic simulation parameters
  # @param resource_hashes [Array<Hash>] List of Hashes specifying simulation
  # resources (Commodities, Agents, etc.)
  # @param scripts [Array<String>] List of script files to be loaded (Ruby)
  # @return [SimData] Newly-constructed SimData
  def self.from_hash(params_hash, resource_hashes, scripts)
    builder = SimDataBuilder.new.params(params_hash)
    scripts.each { |script_file| builder.script(script_file) }
    resource_hashes.each { |resource_hash| builder.resources(resource_hash) }

    builder.build
  end

  # Creates a new SimDataBuilder
  def initialize
    @sim_data = SimData.new
  end

  # Returns the constructed SimData
  #
  # @return [SimData]
  def build
    @sim_data
  end

  # Sets the basic parameters of the simulation
  #
  # @param params_hash [Hash] Specification of the basic simulation parameters
  # @return [SimDataBuilder] self
  def params(params_hash)
    return self if params_hash.nil?

    @sim_data.num_rounds = params_hash['NumRounds']
    @sim_data.num_agents = params_hash['NumAgents']
    @sim_data.starting_funds = params_hash['StartingFunds']
    @sim_data.max_stock = params_hash['MaxStock']

    self
  end

  # Builds and adds resources to the simulation
  #
  # @param resources_hash [Hash] Specification of Commodities and AgentRoles
  # @return [SimDataBuilder] self
  def resources(resources_hash)
    commodities(resources_hash['Commodities'])
    agents(resources_hash['Agents'])
  end

  # Loads Ruby script file containing Condition and/or ProductionRule methods
  #
  # @param script_file [String] Path to Ruby script file
  # @return [SimDataBuilder] self
  def script(script_file)
    load script_file

    self
  end

  # Builds and adds Commodities from the given hash to the simulation
  #
  # @param commodities_hash [Hash] Specification of Commodities
  # @return [SimDataBuilder] self
  def commodities(commodities_hash)
    return self if commodities_hash.nil?

    commodities_hash.each do |commodity_hash|
      @sim_data.add_commodity(Commodity.new(commodity_hash['Name']))
    end

    self
  end

  # Builds and adds AgentRoles from the given hash to the simulation
  #
  # @param agents_hash [Hash] Specification of AgentRoles
  # @return [SimDataBuilder] self
  def agents(agents_hash)
    return self if agents_hash.nil?

    agents_hash.each do |agent_hash|
      @sim_data.add_agent_role(AgentRoleBuilder.from_hash(agent_hash, @sim_data))
    end

    self
  end

  # Reads and parses a JSON file
  #
  # @param filename [String] Path to some JSON file
  # @return [Hash] Parsed JSON data
  def self.read_file(filename)
    JSON.parse(File.readlines(filename).join("\n"))
  end
end
