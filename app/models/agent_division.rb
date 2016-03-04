class AgentDivision < ActiveRecord::Base
  self.table_name = 'crpnpcdivisions'
  self.primary_key = 'divisionID'

  belongs_to :agent, foreign_key: 'divisionID'
end
