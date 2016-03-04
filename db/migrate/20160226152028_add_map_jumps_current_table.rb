class AddMapJumpsCurrentTable < ActiveRecord::Migration
  def change
    create_table :mapjumpscurrent do |t|
      t.integer :solarSystemID
      t.integer :shipJumps
      t.datetime :cachedUntil
    end
  end
end
