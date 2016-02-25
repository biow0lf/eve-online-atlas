class Moonmaterial < ActiveRecord::Base
  self.table_name = 'mapmoons'
  self.primary_key = 'moonID'

  belongs_to :moon, foreign_key: 'itemID'
end
