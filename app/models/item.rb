class Item < ActiveRecord::Base
  self.table_name = 'invTypes'
  self.primary_key = 'typeID'
end
