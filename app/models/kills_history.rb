class KillsHistory < ActiveRecord::Base
  self.table_name = 'mapKillsHistory'
  self.primary_key = 'solarSystemID'

  belongs_to :solarSystem, foreign_key: 'solarSystemID'
end
