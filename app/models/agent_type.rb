class AgentType < ActiveRecord::Base
  self.table_name = 'agtagenttypes'
  self.primary_key = 'agentTypeID'

  belongs_to :agent, foreign_key: 'agentTypeID'
end
