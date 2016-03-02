class Celestial < ActiveRecord::Base
  self.table_name = 'mapDenormalize'
  self.primary_keys = 'itemID'
  has_many :planets, foreign_key: %w(itemID solarSystemID celestialIndex), primary_key: %w(itemID solarSystemID celestialIndex)
  belongs_to :solarSystem, foreign_key: 'solarSystemID', primary_key: 'solarSystemID'
end
