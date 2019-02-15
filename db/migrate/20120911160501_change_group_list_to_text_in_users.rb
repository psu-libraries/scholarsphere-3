class ChangeGroupListToTextInUsers  < ActiveRecord::Migration[4.2]
  def self.up
    change_column :users,  :group_list, :text
  end

end
