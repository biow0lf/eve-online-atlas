class JumpsHistory < ActiveRecord::Base
  self.table_name = 'map_jumps_history'

  belongs_to :solarSystem, foreign_key: 'solarSystemID', primary_key: 'solarSystemID'
end
