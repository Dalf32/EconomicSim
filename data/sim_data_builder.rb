# sim_data_builder.rb
#
# Author::  Kyle Mullins

require 'json'

require_relative 'sim_data'
require_relative 'commodity'
require_relative 'agent_role_builder'

class SimDataBuilder
  def self.from_file(params_file)
    params_hash = SimDataBuilder.read_file(params_file)
    resource_hashes = params_hash['Resources'].map do |resource_file|
      SimDataBuilder.read_file(resource_file)
    end

    SimDataBuilder.from_hash(params_hash, resource_hashes)
  end

  def self.from_hash(params_hash, resource_hashes)
    builder = SimDataBuilder.new.params(params_hash)
    resource_hashes.each { |resource_hash| builder.resources(resource_hash) }

    builder.build
  end

  def initialize
    @sim_data = SimData.new
  end

  def build
    @sim_data
  end

  def params(params_hash)
    return self if params_hash.nil?

    @sim_data.num_rounds = params_hash['NumRounds']
    @sim_data.num_agents = params_hash['NumAgents']
    @sim_data.starting_funds = params_hash['StartingFunds']
    @sim_data.max_stock = params_hash['MaxStock']

    self
  end

  def resources(resources_hash)
    commodities(resources_hash['Commodities'])
    agents(resources_hash['Agents'])
  end

  def commodities(commodities_hash)
    return self if commodities_hash.nil?

    commodities_hash.each do |commodity_hash|
      @sim_data.add_commodity(Commodity.new(commodity_hash['Name']))
    end

    self
  end

  def agents(agents_hash)
    return self if agents_hash.nil?

    agents_hash.each do |agent_hash|
      @sim_data.add_agent_role(AgentRoleBuilder.from_hash(agent_hash, @sim_data))
    end

    self
  end

  def self.read_file(filename)
    JSON.parse(File.readlines(filename).join("\n"))
  end
end
