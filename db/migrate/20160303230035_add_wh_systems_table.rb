class AddWhSystemsTable < ActiveRecord::Migration
  def change
    create_table :wormhole_systems, {id: false} do |t|
      t.integer :solarSystemID
      t.string :wormholeName
      t.integer :wormholeClass
      t.integer :wormHoleEffectName
      t.integer :static1
      t.integer :static2
    end
  end
end
