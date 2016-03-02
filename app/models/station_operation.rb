class StationOperation < ActiveRecord::Base
  self.table_name = 'staoperations'
  self.primary_key = 'activityID'

  belongs_to :station, foreign_key: 'operationID'
end
