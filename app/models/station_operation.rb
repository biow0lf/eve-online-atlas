class StationOperation < ActiveRecord::Base
  self.table_name = 'staOperations'
  self.primary_key = 'activityID'

  belongs_to :station, foreign_key: 'operationID'
end
