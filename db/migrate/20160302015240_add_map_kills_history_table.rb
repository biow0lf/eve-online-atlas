class AddMapKillsHistoryTable < ActiveRecord::Migration
  def change
    create_table :mapkKllsHistory do |t|
      t.integer :solarSystemID
      t.integer :shipKills
      t.integer :factionKills
      t.integer :podKills
      t.datetime :cachedUntil
      t.timestamps null: false
    end
  end
end
