class ChangeUrlToUri < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :subject_local_authority_entries, :url, :uri
  end
  
  def self.down
  end
end
