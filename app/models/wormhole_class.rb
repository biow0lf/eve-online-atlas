class WormholeClass < ActiveRecord::Base
  self.table_name = 'mapLocationWormholeClasses'
  self.primary_key = 'locationID'

  belongs_to :solarSystem, foreign_key: 'regionID'
end
