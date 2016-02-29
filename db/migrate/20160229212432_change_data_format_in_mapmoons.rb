class ChangeDataFormatInMapmoons < ActiveRecord::Migration
  def self.up
    change_column :mapmoons, :atm, :integer
    change_column :mapmoons, :eva, :integer
    change_column :mapmoons, :hyd, :integer
    change_column :mapmoons, :sil, :integer
    change_column :mapmoons, :cob, :integer
    change_column :mapmoons, :sca, :integer
    change_column :mapmoons, :tit, :integer
    change_column :mapmoons, :tun, :integer
    change_column :mapmoons, :cad, :integer
    change_column :mapmoons, :van, :integer
    change_column :mapmoons, :chr, :integer
    change_column :mapmoons, :pla, :integer
    change_column :mapmoons, :cae, :integer
    change_column :mapmoons, :tec, :integer
    change_column :mapmoons, :haf, :integer
    change_column :mapmoons, :mer, :integer
    change_column :mapmoons, :pro, :integer
    change_column :mapmoons, :dys, :integer
    change_column :mapmoons, :neo, :integer
    change_column :mapmoons, :thu, :integer
    change_column :mapmoons, :scan, :integer
  end

  def self.down
    change_column :mapmoons, :atm, :integer, limit: 1
    change_column :mapmoons, :eva, :integer, limit: 1
    change_column :mapmoons, :hyd, :integer, limit: 1
    change_column :mapmoons, :sil, :integer, limit: 1
    change_column :mapmoons, :cob, :integer, limit: 1
    change_column :mapmoons, :sca, :integer, limit: 1
    change_column :mapmoons, :tit, :integer, limit: 1
    change_column :mapmoons, :tun, :integer, limit: 1
    change_column :mapmoons, :cad, :integer, limit: 1
    change_column :mapmoons, :van, :integer, limit: 1
    change_column :mapmoons, :chr, :integer, limit: 1
    change_column :mapmoons, :pla, :integer, limit: 1
    change_column :mapmoons, :cae, :integer, limit: 1
    change_column :mapmoons, :tec, :integer, limit: 1
    change_column :mapmoons, :haf, :integer, limit: 1
    change_column :mapmoons, :mer, :integer, limit: 1
    change_column :mapmoons, :pro, :integer, limit: 1
    change_column :mapmoons, :dys, :integer, limit: 1
    change_column :mapmoons, :neo, :integer, limit: 1
    change_column :mapmoons, :thu, :integer, limit: 1
    change_column :mapmoons, :scan, :integer, limit: 1
  end
end