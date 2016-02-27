class Station < ActiveRecord::Base
  self.table_name = 'staStations'
  self.primary_key = 'stationID'

  belongs_to :solarsystem, foreign_key: 'solarSystemID'
  has_many :agents, foreign_key: 'locationID'
  has_many :stationoperations, foreign_key: 'operationID', primary_key: 'operationID'

end
