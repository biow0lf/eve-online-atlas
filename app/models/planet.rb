class Planet < Celestial
  self.primary_key = 'itemID'
  belongs_to :celestial, foreign_key: %w(solarSystemID celestialIndex), primary_key: %w(solarSystemID celestialIndex)
  has_many :moons, foreign_key: %w(solarSystemID celestialIndex), primary_key: %w(solarSystemID celestialIndex)
  has_one :celestialstatistic, foreign_key: 'celestialID'
  def self.default_scope
    where(groupID: 7)
  end
end
