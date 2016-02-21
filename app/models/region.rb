class Region < ActiveRecord::Base
  self.table_name = 'mapRegions'
  self.primary_key = 'regionID'

  has_many :solarsystems, foreign_key: 'regionID'
end
