class CreateQaLocalAuthorityEntries < ActiveRecord::Migration
  def change
    create_table :qa_local_authority_entries do |t|
      t.integer :local_authority_id, index: true
      t.string :label
      t.string :uri
      t.string :lower_label

      t.timestamps null: false
    end
    add_index :qa_local_authority_entries, :uri, unique: true
    add_foreign_key :qa_local_authority_entries, :qa_local_authorities, column: :local_authority_id
    if defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter) && ActiveRecord::Base.connection.instance_of?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
       remove_column :qa_local_authority_entries, :lower_label, :string
       execute("alter table qa_local_authority_entries add lower_label varchar(256) GENERATED ALWAYS AS (lower(label)) VIRTUAL")
    end
    add_index :qa_local_authority_entries, [:lower_label, :local_authority_id], name: 'index_qa_local_authority_entries_on_lower_label_and_authority'
  end
end
