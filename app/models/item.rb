class Item < ActiveRecord::Base
  self.table_name = 'invTypes'
  self.primary_key = 'typeID'

  has_many :itemhistories, foreign_key: 'typeID', primary_key: 'typeID'
end
