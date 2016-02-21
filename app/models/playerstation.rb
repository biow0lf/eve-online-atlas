class Playerstation < ActiveRecord::Base
  self.table_name = 'playerstations'
  self.primary_key = 'stationID'

  belongs_to :solarsystem, foreign_key: 'solarSystemID'
end
