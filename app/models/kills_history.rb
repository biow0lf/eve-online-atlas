class KillsHistory < ActiveRecord::Base
  self.table_name = 'map_kills_history'
  self.primary_key = 'solarSystemID'

  belongs_to :solarSystem, foreign_key: 'solarSystemID'
end
