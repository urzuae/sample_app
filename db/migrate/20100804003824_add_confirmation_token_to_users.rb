class AddConfirmationTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :confirmation_token, :string
    add_column :users, :state, :string
  end

  def self.down
    remove_column :users, :confirmation_token
  end
end
