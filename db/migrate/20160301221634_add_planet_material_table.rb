class AddPlanetMaterialTable < ActiveRecord::Migration
  def change
    create_table :planetmaterials do |t|
      t.integer :typeID
      t.string  :materialType
    end
  end
end
