class WormholeEffect < ActiveRecord::Base
  self.table_name = 'wormhole_effects'
  self.primary_key = 'effectID'

  belongs_to :WormholeSystem, foreign_key: %w(wormholeClass effectID), primary_key: %w(wormholeClass effectID)
end
