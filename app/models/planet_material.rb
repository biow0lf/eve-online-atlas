class PlanetMaterial < ActiveRecord::Base
  self.table_name = 'planetMaterials'
  self.primary_key = 'typeID'

  belongs_to :planet, foreign_key: 'typeID'
end
