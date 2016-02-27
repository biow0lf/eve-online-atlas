class Stationservice < ActiveRecord::Base
  self.table_name = 'staservices'
  self.primary_key = 'serviceID'

  belongs_to :stationoperation, foreign_key: 'serviceID'
end
