class WormholeType < ActiveRecord::Base
  self.table_name = 'wormhole_types'
  self.primary_key = 'wormholeID'

  belongs_to :WormholeSystem, foreign_key: 'static1', primary_key: 'wormholeID'
end
