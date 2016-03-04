class Station < ActiveRecord::Base
  self.table_name = 'staStations'
  self.primary_key = 'stationID'

  belongs_to :solarSystem, foreign_key: 'solarSystemID'
  has_many :agents, foreign_key: 'locationID'
  has_many :operationServices, foreign_key: 'operationID', primary_key: 'operationID'
  has_many :stationServices, through: :operationServices, foreign_key: 'serviceID'
  has_one :stationOperation, foreign_key: 'operationID', primary_key: 'operationID'
end
