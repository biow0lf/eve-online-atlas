class SystemCostIndex < ActiveRecord::Base
  self.table_name = 'systemcostindex'
  self.primary_key = 'solarSystemID'

  belongs_to :solarSystem, foreign_key: 'solarSystemID'
end
