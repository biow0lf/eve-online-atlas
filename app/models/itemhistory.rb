class ItemHistory < ActiveRecord::Base
  self.table_name = 'itemHistory'
  self.primary_key = 'id'

  belongs_to :item, foreign_key: 'typeID', primary_key: 'typeID'
end
