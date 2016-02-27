class Systemcostindex < ActiveRecord::Base
  self.table_name = 'systemcostindex'
  self.primary_key = 'solarSystemID'

  belongs_to :solarsystem, foreign_key: 'solarSystemID'
end
