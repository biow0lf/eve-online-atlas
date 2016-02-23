class Moon < Planet
  self.primary_keys = 'solarSystemID', 'celestialIndex', 'orbitIndex'
  belongs_to :planet, foreign_key: [:celestialID, :solarSystemID]
  has_one :celestialstatistic, foreign_key: 'celestialID', primary_key: 'itemID'
  has_one :moonmaterial, foreign_key: 'moonID', primary_key: 'itemID'
  def self.default_scope
    where(groupID: 8)
  end
end
