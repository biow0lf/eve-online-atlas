class Stationservice < ActiveRecord::Base
  self.table_name = 'staservices'
  self.primary_key = 'serviceID'

  belongs_to :operationservice, foreign_key: 'serviceID'
end
