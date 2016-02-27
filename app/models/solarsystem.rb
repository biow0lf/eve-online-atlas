class Solarsystem < ActiveRecord::Base
  self.table_name = 'mapSolarSystems'
  self.primary_key = 'solarSystemID'
  belongs_to :region, foreign_key: 'regionID'
  has_many :stations, foreign_key: 'solarSystemID'
  has_many :playerstations, foreign_key: 'solarSystemID'
  has_many :jumpcurrents, foreign_key: 'solarSystemID'
  has_many :killcurrents, foreign_key: 'solarSystemID'
  has_many :celestials, foreign_key: 'solarSystemID'
  has_many :planets, through: :celestials, foreign_key: 'solarSystemID'
  has_one :wormholeclass, foreign_key: 'locationID', primary_key: 'regionID'
end
