class PlanetMaterial < ActiveRecord::Base
  self.table_name = 'planet_materials'
  self.primary_key = 'typeID'

  belongs_to :planet, foreign_key: 'typeID'
end
