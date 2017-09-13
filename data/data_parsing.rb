# data_parsing.rb

require 'json'

require_relative 'sim_data'
require_relative 'commodity'
require_relative '../agent_role'
require_relative '../conditions'
require_relative '../variables'
require_relative '../production_rule'

class DataParser
  def self.parse_spec(filename)
    raw_json = DataParser.read_file(filename)
    parsed_json = JSON.parse(raw_json)

    parsed_json.each_pair do |key, value|
      case key
      when Commodity.json_name
        value.each do |commodity_json|
          SimData.instance.add_commodity(Commodity.from_json(commodity_json))
        end
      when AgentRole.json_name
        value.each do |agent_json|
          SimData.instance.add_agent_role(AgentRole.from_json(agent_json))
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

  private_class_method :read_file
end

class Commodity
  def self.json_name
    'Commodities'
  end

  def self.from_json(parsed_json)
    Commodity.new(parsed_json['Name'])
  end
end

class AgentRole
  def self.json_name
    'Agents'
  end

  def self.from_json(parsed_json)
    name = parsed_json['Name']
    role = AgentRole.new(name, SimData.instance.commodities)

    parsed_json.each_pair do |key, value|
      case key
      when 'Name'
        next
      when Condition.json_name
        value.each do |condition_json|
          Condition.from_json(condition_json).each_pair do |id, condition|
            role.add_condition(id, condition)
          end
        end
      when Variable.json_name
        value.each do |variable_json|
          Variable.from_json(variable_json).each_pair do |id, variable|
            role.add_variable(id, variable)
          end
        end
      when ProductionRule.json_name
        value.each do |rule_json|
          role.add_production_rule(ProductionRule.from_json(rule_json))
        end
      when Commodity.json_name
        value.each do |preference_json|
          commodity = SimData.instance.get_commodity(preference_json['Name'])
          buys = preference_json['Buys?']
          sells = preference_json['Sells?']
          ideal_stock = preference_json['Ideal Stock']

          role.set_commodity_prefs(commodity, ideal_stock, buys, sells)
        end
      else
        raise 'Illegal AgentRole JSON'
      end
    end

    role
  end
end

class Condition
  def self.json_name
    'Conditions'
  end

  def self.from_json(parsed_json)
    id = parsed_json['ID']

    case parsed_json['Type']
    when 'HasCommodity'
      commodity = SimData.instance.get_commodity(parsed_json['Commodity'])
      { id => HasCommodityCondition.new(commodity) }
    when 'Chance'
      chance = parsed_json['Chance']
      { id => ChanceCondition.new(chance) }
    else
      raise 'Illegal Condition JSON'
    end
  end
end

class Variable
  def self.json_name
    'Variables'
  end

  def self.from_json(parsed_json)
    id = parsed_json['ID']

    case parsed_json['Type']
    when 'CommodityQuantity'
      commodity = SimData.instance.get_commodity(parsed_json['Commodity'])
      { id => CommodityQuantityVariable.new(commodity) }
    when 'NegateVariable'
      variable_id = parsed_json['Variable']
      { id => NegateVariable.new(variable_id) }
    else
      raise 'Illegal Variable JSON'
    end
  end
end

class ProductionRule
  def self.json_name
    'Productions'
  end

  def self.from_json(parsed_json)
    commodity = SimData.instance.get_commodity(parsed_json['Commodity'])
    condition_ids = parsed_json['Conditions']

    case parsed_json['Amount']
    when 'Variable'
      variable_id = parsed_json['Variable']
      VariableProductionRule.new(commodity, condition_ids, variable_id)
    else
      amount = parsed_json['Amount']
      FixedProductionRule.new(commodity, condition_ids, amount)
    end
  end
end
