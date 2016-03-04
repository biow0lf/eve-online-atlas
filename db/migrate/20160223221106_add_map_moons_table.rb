class AddMapMoonsTable < ActiveRecord::Migration
  def change
    create_table :mapmoons, {id: false} do |t|
      t.integer :moonID, primary_key: true, null: false, default: 0
      t.integer :atm, limit: 1, null: true, default: -1
      t.integer :eva, limit: 1, null: true, default: -1
      t.integer :hyd, limit: 1, null: true, default: -1
      t.integer :sil, limit: 1, null: true, default: -1
      t.integer :cob, limit: 1, null: true, default: -1
      t.integer :sca, limit: 1, null: true, default: -1
      t.integer :tit, limit: 1, null: true, default: -1
      t.integer :tun, limit: 1, null: true, default: -1
      t.integer :cad, limit: 1, null: true, default: -1
      t.integer :van, limit: 1, null: true, default: -1
      t.integer :chr, limit: 1, null: true, default: -1
      t.integer :pla, limit: 1, null: true, default: -1
      t.integer :cae, limit: 1, null: true, default: -1
      t.integer :tec, limit: 1, null: true, default: -1
      t.integer :haf, limit: 1, null: true, default: -1
      t.integer :mer, limit: 1, null: true, default: -1
      t.integer :pro, limit: 1, null: true, default: -1
      t.integer :dys, limit: 1, null: true, default: -1
      t.integer :neo, limit: 1, null: true, default: -1
      t.integer :thu, limit: 1, null: true, default: -1
      t.integer :scan, limit: 1, null: true, default: -1
    end
  end
end