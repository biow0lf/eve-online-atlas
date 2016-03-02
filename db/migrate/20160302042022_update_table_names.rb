class UpdateTableNames < ActiveRecord::Migration
  def change
    rename_table :mapjumpscurrent, :map_jumps_current
    rename_table :mapkillscurrent, :map_kills_current
    rename_table :planetmaterials, :planet_materials
    rename_table :playerstations, :player_stations
    rename_table :mapmoons, :map_moons
    rename_table :systemcostindex, :system_cost_indices
    rename_table :itemHistory, :item_history
  end
end
