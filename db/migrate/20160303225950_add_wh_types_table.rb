class AddWhTypesTable < ActiveRecord::Migration
  def change
    create_table :wormhole_types, {id: false} do |t|
      t.integer :wormholeID
      t.string :wormholeName
      t.string :source
      t.string :destination
      t.integer :lifeTime
      t.integer :jumpMass
      t.integer :maxMass
    end
  end
end
