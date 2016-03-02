class JumpsCurrent < ActiveRecord::Base
  self.table_name = 'mapJumpsCurrent'
  self.primary_key = 'solarSystemID'

  belongs_to :solarSystem, foreign_key: 'solarSystemID'
end
