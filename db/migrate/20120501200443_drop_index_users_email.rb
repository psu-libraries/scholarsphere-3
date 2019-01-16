class DropIndexUsersEmail < ActiveRecord::Migration[4.2]
  def up
    remove_index :users, :email
  end

  def down
    add_index :users, :email, unique:true
  end
end
