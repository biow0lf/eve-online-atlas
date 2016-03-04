class WormholeSystem < ActiveRecord::Base
  self.table_name = 'wormhole_systems'
  self.primary_key = 'solarSystemID'

  has_many :WormholeEffects, foreign_key: %w(effectID wormholeClass), primary_key: %w(wormHoleEffectName wormholeClass)
  has_one :static1, class_name: 'WormholeStatic',  foreign_key: 'wormholeID', primary_key: 'static1'
  has_one :static2, class_name: 'WormholeStatic',  foreign_key: 'wormholeID', primary_key: 'static2'
end
