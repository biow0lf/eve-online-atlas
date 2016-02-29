class Constellation < ActiveRecord::Base
  self.table_name = 'mapConstellations'
  self.primary_key = 'constellationID'

  belongs_to :region, foreign_key: 'constellationID'
end
