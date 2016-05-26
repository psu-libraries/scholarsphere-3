class ChangeFeaturedWorkGenericWorkIdToWorkId < ActiveRecord::Migration
  def change
    rename_column :featured_works, :generic_work_id, :work_id
  end
end
