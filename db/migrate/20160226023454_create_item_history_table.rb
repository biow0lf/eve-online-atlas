class CreateItemHistoryTable < ActiveRecord::Migration
  def change
    create_table :itemHistory do |t|
      t.integer :typeID, unsigned: true
      t.integer :orderCount, unsigned: true, limit: 8
      t.float :lowPrice, scale: 2
      t.float :highPrice, scale: 2
      t.float :avgPrice, scale: 2
      t.integer :volume, unsigned: true, limit: 8
      t.datetime :date
      t.timestamps null: false
    end
    add_index :itemHistory, :typeID
  end
end
