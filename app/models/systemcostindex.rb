class Systemcostindex < ActiveRecord::Base
  self.table_name = 'staservices'
  self.primary_key = 'serviceID'

  belongs_to :solarsystem, foreign_key: 'serviceID'
end
