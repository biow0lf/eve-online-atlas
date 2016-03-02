class Moon < Planet
  self.primary_key = 'itemID'
  belongs_to :planet, foreign_key: %w(celestialID solarSystemID), primary_key: %w(itemID solarSystemID)
  has_one :celestialStatistic, foreign_key: 'celestialID'
  has_one :moonMaterial, foreign_key: 'moonID'
  def self.default_scope
    where(groupID: 8)
  end
end
