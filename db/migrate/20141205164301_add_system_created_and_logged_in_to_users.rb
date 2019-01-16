class AddSystemCreatedAndLoggedInToUsers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :system_created, :boolean, default: false
    add_column :users, :logged_in, :boolean, default: true
  end

  def self.down
    remove_column :users, :system_created
    remove_column :users, :logged_in
  end
end
