class AddMapKillsCurrentTable < ActiveRecord::Migration
  def change
    create_table :mapkillscurrent do |t|
      t.integer :solarSystemID
      t.integer :shipKills
      t.integer :factionKills
      t.integer :podKills
      t.datetime :cachedUntil
    end
  end
end
