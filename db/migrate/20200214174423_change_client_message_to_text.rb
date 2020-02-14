class ChangeClientMessageToText < ActiveRecord::Migration[5.1]
  def change
    change_column :migration_resources, :client_message, :text
  end
end
