class AddSystemCostIndexTable < ActiveRecord::Migration
  def change
    create_table :systemcostindex do |t|
      t.integer :solarSystemID
      t.string  :inventionIndex
      t.string  :manufacturingIndex
      t.string  :copyingIndex
      t.string  :timeResearchIndex
      t.string  :materialResearchIndex
    end
  end
end
