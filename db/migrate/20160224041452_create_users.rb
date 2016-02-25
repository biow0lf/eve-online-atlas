class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :characterID
      t.integer :uid
      t.string :refreshToken
      t.timestamps null: false
    end
    add_index :users, :characterID, unique: true
  end
end
