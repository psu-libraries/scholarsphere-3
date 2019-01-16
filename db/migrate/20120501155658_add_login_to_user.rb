class AddLoginToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :login, :string, null:false, default:''
    change_column :users, :email, :string, null:true
    change_column :users, :encrypted_password, :string, null:true
    add_index :users, :login, unique:true
  end
end
