class Moon < ActiveRecord::Base
  self.table_name = 'mapDenormalize'
  self.primary_keys = [:solarSystemID, :celestialIndex]
  belongs_to :planet, foreign_key: [:solarSystemID, :celestialIndex]
  has_one :celestialStatistic, foreign_key: 'celestialID', primary_key: 'itemID'
  has_one :moonMaterial, foreign_key: 'moonID', primary_key: 'itemID'
  def self.default_scope
    where(groupID: 8)
  end
end
