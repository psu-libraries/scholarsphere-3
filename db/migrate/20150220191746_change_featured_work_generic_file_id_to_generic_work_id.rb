class ChangeFeaturedWorkGenericFileIdToGenericWorkId < ActiveRecord::Migration
  def change
    rename_column :featured_works, :generic_file_id, :generic_work_id
  end
end
