class AddDefaultCreateDate < ActiveRecord::Migration
  def change
    change_column_default(:subject_local_authority_entries, :created_at, Time.now)
    change_column_default(:subject_local_authority_entries, :updated_at, Time.now)
  end
end
