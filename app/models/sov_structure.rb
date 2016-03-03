class SovStructure < ActiveRecord::Base
  self.table_name = 'sovStructures'
  self.primary_key = 'solarSystemID'

  belongs_to :solarSystem, foreign_key: 'solarSystemID'
end
