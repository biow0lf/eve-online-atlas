class AddPlayerstationsTable < ActiveRecord::Migration
  def change
    create_table :playerstations do |t|
      t.integer :stationID
      t.string :stationName
      t.integer :stationTypeID
      t.integer :solarSystemID
      t.integer :corporationID
      t.string :corporationName
      t.float :x, limit: 24
      t.float :y, limit: 24
      t.float :z, limit: 24

      t.timestamps null: false
    end
  end
end
