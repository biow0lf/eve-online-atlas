class Solarsystem < ActiveRecord::Base
  self.table_name = 'mapSolarSystems'
  self.primary_key = 'solarSystemID'

  belongs_to :region, foreign_key: 'regionID'
  has_many :stations, foreign_key: 'solarSystemID'
end
