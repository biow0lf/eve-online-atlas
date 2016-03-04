class OperationService < ActiveRecord::Base
  self.table_name = 'staOperationServices'
  self.primary_key = 'operationID'

  belongs_to :station, foreign_key: 'operationID'
  has_many :stationServices, foreign_key: 'serviceID', primary_key: 'serviceID'
end
