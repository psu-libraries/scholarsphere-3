class DropSubjectLocalAuthorityEntries < ActiveRecord::Migration[4.2]
  def change
    drop_table :subject_local_authority_entries
  end
end
