class CelestialStatistic < ActiveRecord::Base
  self.table_name = 'mapCelestialStatistics'
  self.primary_key = 'celestialID'

  belongs_to :planet, foreign_key: 'itemID'
  belongs_to :moon, foreign_key: 'itemID'
end
