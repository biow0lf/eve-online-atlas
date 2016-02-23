class Celestial < ActiveRecord::Base
  self.table_name = 'mapDenormalize'
  self.primary_keys = 'itemID'
  has_many :planets, foreign_key: ['solarSystemID', 'celestialIndex'], primary_key: ['solarSystemID', 'celestialIndex']
  belongs_to :solarsystem, foreign_key: 'solarSystemID', primary_key: 'solarSystemID'
end
