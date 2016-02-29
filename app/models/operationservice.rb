class Operationservice < ActiveRecord::Base
  self.table_name = 'staoperationservices'
  self.primary_key = 'operationID'

  belongs_to :station, foreign_key: 'operationID'
  has_many :stationservices, foreign_key: 'serviceID', primary_key: 'serviceID'
end
