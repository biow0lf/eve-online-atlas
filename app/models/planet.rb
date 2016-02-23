class Planet < Celestial
  self.primary_keys = 'solarSystemID', 'celestialIndex'
  belongs_to :celestial, foreign_key: ['solarSystemID', 'celestialIndex']
  has_many :moons, foreign_key: ['solarSystemID', 'celestialIndex']
  def self.default_scope
    where(groupID: 7)
  end
end
