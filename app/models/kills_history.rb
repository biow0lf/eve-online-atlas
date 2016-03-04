class KillsHistory < ActiveRecord::Base
  self.table_name = 'map_kills_history'

  belongs_to :solarSystem, foreign_key: 'solarSystemID', primary_key: 'solarSystemID'
end
