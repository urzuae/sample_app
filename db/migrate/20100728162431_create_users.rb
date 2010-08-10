class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string  :username
      t.string  :name
      t.string  :email
      t.boolean :mail_option, :default => true

      t.timestamps
    end
    add_index :users, :username, :unique => true
  end

  def self.down
    drop_table :users
  end
end
