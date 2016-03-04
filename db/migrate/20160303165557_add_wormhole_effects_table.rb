class AddWormholeEffectsTable < ActiveRecord::Migration
  def change
    create_table :wormhole_effects, {id: false} do |t|
      t.integer :effectID
      t.string :effectName
      t.string :wormholeClass
      t.string :attributeName
      t.float :effectValue
    end
  end
end
