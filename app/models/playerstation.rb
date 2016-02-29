class Playerstation < ActiveRecord::Base
  self.table_name = 'playerstations'
  self.primary_key = 'stationID'

  belongs_to :solarsystem, foreign_key: 'solarSystemID'
  has_many :operationservices, foreign_key: 'operationID', primary_key: 'operationID'
  has_many :stationservices, through: :operationservices, foreign_key: 'serviceID'
  has_one :stationoperation, foreign_key: 'operationID', primary_key: 'operationID'
end
