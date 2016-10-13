class DropSubjectLocalAuthorityEntries < ActiveRecord::Migration
  def change
    drop_table :subject_local_authority_entries
  end
end
