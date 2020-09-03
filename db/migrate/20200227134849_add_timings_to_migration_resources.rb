class AddTimingsToMigrationResources < ActiveRecord::Migration[5.1]
  def change
    add_column :migration_resources, :started_at, :datetime
    add_column :migration_resources, :completed_at, :datetime
  end
end
