class SystemCostIndex < ActiveRecord::Base
  self.table_name = 'system_cost_indices'
  self.primary_key = 'solarSystemID'

  belongs_to :solarSystem, foreign_key: 'solarSystemID'
end
