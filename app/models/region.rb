class Region < ActiveRecord::Base
  self.table_name = 'mapRegions'
  self.primary_key = 'regionID'

  has_many :solarSystems, foreign_key: 'regionID'
  has_many :constellations, foreign_key: 'regionID'
end
