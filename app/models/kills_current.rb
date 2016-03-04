class KillsCurrent < ActiveRecord::Base
  self.table_name = 'map_kills_current'

  belongs_to :solarSystem, foreign_key: 'solarSystemID', primary_key: 'solarSystemID'
end
