class ChangeFeaturedWorkGenericWorkIdToWorkId < ActiveRecord::Migration[4.2]
  def change
    rename_column :featured_works, :generic_work_id, :work_id
  end
end
