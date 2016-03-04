class WormholeEffect < ActiveRecord::Base
  self.table_name = 'wormhole_effects'
  self.primary_key = 'wormHoleID'

  belongs_to :WormholeSystem, foreign_key: %w(effectID wormholeClass), primary_key: %w(wormholeClass wormHoleEffectName)
end
