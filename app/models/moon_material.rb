class MoonMaterial < ActiveRecord::Base
  self.table_name = 'map_moons'
  self.primary_key = 'moonID'

  belongs_to :moon, foreign_key: 'itemID'
end
