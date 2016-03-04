class AddSovStructuresTable < ActiveRecord::Migration
  def change
    create_table :sovStructures do |t|
      t.integer :solarSystemID
      t.integer :allianceID
      t.float :occupancyLevel
      t.integer :structureID, :limit => 8
      t.integer :structureTypeID
      t.datetime :vulnerableStartTime
      t.datetime :vulnerableEndTime
    end
  end
end
