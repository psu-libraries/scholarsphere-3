class AddDefaultCreateDate < ActiveRecord::Migration[4.2]
  def change
    change_column_default(:subject_local_authority_entries, :created_at, Time.now)
    change_column_default(:subject_local_authority_entries, :updated_at, Time.now)
  end
end
