class AddMapJumpsHistoryTable < ActiveRecord::Migration
  def change
    create_table :mapJumpsHistory do |t|
      t.integer :solarSystemID
      t.integer :shipJumps
      t.datetime :cachedUntil
      t.timestamps null: false
    end
  end
end
