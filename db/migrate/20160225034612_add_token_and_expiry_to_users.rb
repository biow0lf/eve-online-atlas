class AddTokenAndExpiryToUsers < ActiveRecord::Migration
  def change
    add_column :users, :token, :string
    add_column :users, :expiry, :datetime
  end
end
