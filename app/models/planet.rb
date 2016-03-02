class Planet < Celestial
  self.primary_key = 'itemID'
  belongs_to :celestial, foreign_key: %w(solarSystemID celestialIndex), primary_key: %w(solarSystemID celestialIndex)
  has_many :moons, foreign_key: %w(solarSystemID celestialIndex), primary_key: %w(solarSystemID celestialIndex)
  has_many :planetMaterials, foreign_key: 'typeID', primary_key: 'typeID'
  has_one :celestialStatistic, foreign_key: 'celestialID'
  def self.default_scope
    where(groupID: 7)
  end
end
