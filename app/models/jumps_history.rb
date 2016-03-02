class JumpsHistory < ActiveRecord::Base
  self.table_name = 'mapJumpsHistory'
  self.primary_key = 'solarSystemID'

  belongs_to :solarSystem, foreign_key: 'solarSystemID'
end
