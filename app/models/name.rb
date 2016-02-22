class Name < ActiveRecord::Base
  self.table_name = 'invUniqueNames'
  self.primary_key = 'itemID'
  
	belongs_to :agent, foreign_key: 'agentID'
  
end
