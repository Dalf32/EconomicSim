# variable_builder.rb
#
# Author::  Kyle Mullins

require_relative 'sim_data'
require_relative 'variables/variables'

class VariableBuilder
  def self.from_hash(variable_hash)
    id = variable_hash['ID']

    case variable_hash['Type']
    when 'CommodityQuantity'
      commodity = SimData.instance.get_commodity(variable_hash['Commodity'])
      { id => CommodityQuantityVariable.new(commodity) }
    when 'NegateVariable'
      variable_id = variable_hash['Variable']
      { id => NegateVariable.new(variable_id) }
    else
      raise 'Illegal Variable JSON'
    end
  end
end
