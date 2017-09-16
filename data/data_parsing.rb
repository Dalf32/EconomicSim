# data_parsing.rb
#
# Author::  Kyle Mullins

require 'json'

require_relative 'sim_data'
require_relative 'commodity'
require_relative 'agent_role_builder'

class DataParser
  def self.parse_spec(filename)
    raw_json = DataParser.read_file(filename)
    parsed_json = JSON.parse(raw_json)

    parsed_json.each_pair do |key, value|
      case key
      when 'Commodities'
        value.each do |commodity_hash|
          SimData.instance.add_commodity(Commodity.new(commodity_hash['Name']))
        end
      when 'Agents'
        value.each do |agent_hash|
          SimData.instance.add_agent_role(AgentRoleBuilder.from_hash(agent_hash))
        end
      else
        raise 'Illegal JSON'
      end
    end
  end

  def self.parse_params(filename)
    raw_json = DataParser.read_file(filename)
    JSON.parse(raw_json)['Parameters']
  end

  def self.read_file(filename)
    json = ''

    File.open(filename, 'r') do |file_io|
      json = file_io.read
    end

    json
  end
end
