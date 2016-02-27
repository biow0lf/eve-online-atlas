class Jumpcurrent < ActiveRecord::Base
  self.table_name = 'mapjumpscurrent'
  self.primary_key = 'solarSystemID'

  belongs_to :solarsystem, foreign_key: 'solarSystemID'
end
