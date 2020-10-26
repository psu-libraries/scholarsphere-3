class CreateMigrationResources < ActiveRecord::Migration[5.1]
  def change
    create_table :migration_resources do |t|
      t.string :pid
      t.string :model
      t.string :client_status
      t.string :client_message
      t.string :exception
      t.string :error

      t.timestamps
    end
  end
end
