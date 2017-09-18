# variable_builder.rb
#
# Author::  Kyle Mullins

require_relative 'sim_data'
require_relative 'variables/variables'

class VariableBuilder
  def self.from_hash(variable_hash, sim_data)
    id = variable_hash['ID']

    case variable_hash['Type']
    when 'CommodityQuantity'
      commodity = sim_data.get_commodity(variable_hash['Commodity'])
      CommodityQuantityVariable.new(id, commodity)
    when 'NegateVariable'
      variable_id = variable_hash['Variable']
      NegateVariable.new(id, variable_id)
    else
      raise 'Illegal Variable JSON'
    end
  end
end
