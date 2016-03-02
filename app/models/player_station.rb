class PlayerStation < ActiveRecord::Base
  self.table_name = 'playerstations'
  self.primary_key = 'stationID'

  belongs_to :solarSystem, foreign_key: 'solarSystemID'
  has_many :operationServices, foreign_key: 'operationID', primary_key: 'operationID'
  has_many :stationServices, through: :operationServices, foreign_key: 'serviceID'
  has_one :stationOperation, foreign_key: 'operationID', primary_key: 'operationID'
end
