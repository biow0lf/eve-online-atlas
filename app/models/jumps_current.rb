class JumpsCurrent < ActiveRecord::Base
  self.table_name = 'map_jumps_current'
  self.primary_key = 'solarSystemID'

  belongs_to :solarSystem, foreign_key: 'solarSystemID'
end
