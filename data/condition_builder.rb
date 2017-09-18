# condition_builder.rb
#
# Author::  Kyle Mullins

require_relative 'sim_data'
require_relative 'conditions/conditions'

class ConditionBuilder
  def self.from_hash(condition_hash, sim_data)
    id = condition_hash['ID']

    case condition_hash['Type']
    when 'HasCommodity'
      commodity = sim_data.get_commodity(condition_hash['Commodity'])
      HasCommodityCondition.new(id, commodity)
    when 'Chance'
      chance = condition_hash['Chance']
      ChanceCondition.new(id, chance)
    else
      raise 'Illegal Condition JSON'
    end
  end
end
