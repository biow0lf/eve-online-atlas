class StationService < ActiveRecord::Base
  self.table_name = 'staServices'
  self.primary_key = 'serviceID'

  belongs_to :operationService, foreign_key: 'serviceID'
end
