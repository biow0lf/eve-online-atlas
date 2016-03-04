class Agent < ActiveRecord::Base
  self.table_name = 'agtAgents'
  self.primary_key = 'agentID'

  belongs_to :station, foreign_key: 'locationID', primary_key: 'locationID'
  has_one :agentName, foreign_key: 'itemID'
  has_one :agentType, foreign_key: 'agentTypeID', primary_key: 'agentTypeID'
  has_one :agentDivision, foreign_key: 'divisionID', primary_key: 'divisionID'
end
