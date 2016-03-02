class MapSolarSystemJump < ActiveRecord::Base
  self.table_name = 'mapSolarSystemJumps'
  self.primary_keys = ['fromSolarSystemID', 'toSolarSystemID']

  belongs_to :solarSystem, foreign_key: 'solarSystemID', primary_key: 'fromSolarSystemID'
  belongs_to :toSolarSystem, :class_name => SolarSystem, foreign_key: 'toSolarSystemID'

end
