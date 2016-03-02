class Agent < ActiveRecord::Base
  self.table_name = 'agtAgents'
  self.primary_key = 'agentID'

  belongs_to :station, foreign_key: 'locationID', primary_key: 'locationID'
  has_one :agentName, foreign_key: 'itemID'
end
