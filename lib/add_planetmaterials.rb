module AddPlanetMaterials
  def self.add_planetMaterials
    include HTTParty
    to_load = []

    planets = Planetmaterial.find_by_sql("SELECT planet.typeID, pi.typeName
FROM invTypes planet, invTypes pi, dgmTypeAttributes dgmPlanet, dgmTypeAttributes dgmPi
WHERE dgmPlanet.typeID = dgmPi.typeID
AND dgmPlanet.attributeID = 1632 AND dgmPlanet.valueFloat = planet.typeID
AND dgmPi.attributeID = 709 AND dgmPi.valueFloat = pi.typeID
AND pi.published = 1")

    planets.each do |sys|
      to_load << Planetmaterial.new(typeID: sys.typeID.to_i, materialType: sys.typeName.to_s)
    end

    Planetmaterial.import to_load
  end
end
