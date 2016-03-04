class Planet < ActiveRecord::Base
  self.table_name = 'mapDenormalize'
  self.primary_keys = [:solarSystemID, :celestialIndex]
  # belongs_to :celestial, foreign_key: %w(solarSystemID celestialIndex), primary_key: %w(solarSystemID celestialIndex)
  has_many :moons, foreign_key: [:solarSystemID, :celestialIndex]
  has_many :planetMaterials, foreign_key: 'typeID', primary_key: 'typeID'
  has_one :celestialStatistic, foreign_key: 'celestialID', primary_key: 'itemID'
  def self.default_scope
    where(groupID: 7)
  end
end
