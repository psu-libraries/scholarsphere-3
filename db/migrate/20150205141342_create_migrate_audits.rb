class CreateMigrateAudits < ActiveRecord::Migration[4.2]
  def change
    create_table :migrate_audits do |t|
      t.string :f3_pid
      t.string :f3_model
      t.string :f3_title
      t.string :f4_id

      t.timestamps
    end
  end
end
