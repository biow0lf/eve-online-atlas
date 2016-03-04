class ChangeHistoryTableNames < ActiveRecord::Migration
  def change
    rename_table :mapJumpsHistory, :map_jumps_history
    rename_table :mapkKllsHistory, :map_kills_history
  end
end
