class Mapsolarsystemjump < ActiveRecord::Base
  self.table_name = 'mapSolarSystemJumps'
  self.primary_keys = ['fromSolarSystemID', 'toSolarSystemID']

  belongs_to :solarsystem, foreign_key: 'solarSystemID', primary_key: 'fromSolarSystemID'
  belongs_to :tosolarsystem, :class_name => Solarsystem, foreign_key: 'toSolarSystemID'

end
