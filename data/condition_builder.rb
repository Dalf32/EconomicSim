# condition_builder.rb
#
# Author::  Kyle Mullins

require_relative 'sim_data'
require_relative 'conditions/conditions'

class ConditionBuilder
  def self.from_hash(condition_hash)
    id = condition_hash['ID']

    case condition_hash['Type']
    when 'HasCommodity'
      commodity = SimData.instance.get_commodity(condition_hash['Commodity'])
      { id => HasCommodityCondition.new(commodity) }
    when 'Chance'
      chance = condition_hash['Chance']
      { id => ChanceCondition.new(chance) }
    else
      raise 'Illegal Condition JSON'
    end
  end
end
