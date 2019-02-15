class AddStatusToMigrateAudits < ActiveRecord::Migration[4.2]
  def change
    add_column :migrate_audits, :status, :string
  end
end
