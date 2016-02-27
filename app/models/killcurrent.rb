class Killcurrent < ActiveRecord::Base
  self.table_name = 'mapkillscurrent'
  self.primary_key = 'solarSystemID'

  belongs_to :solarsystem, foreign_key: 'solarSystemID'
end
