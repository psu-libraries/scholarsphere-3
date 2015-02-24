class AddStatusToMigrateAudits < ActiveRecord::Migration
  def change
    add_column :migrate_audits, :status, :string
  end
end
