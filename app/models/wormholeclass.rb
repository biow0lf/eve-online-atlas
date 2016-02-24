class Wormholeclass < ActiveRecord::Base
  self.table_name = 'maplocationwormholeclasses'
  self.primary_key = 'locationID'

  belongs_to :solarsystem, foreign_key: 'locationID', primary_key: 'regionID'
end
