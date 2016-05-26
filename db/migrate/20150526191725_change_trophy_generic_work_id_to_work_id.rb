class ChangeTrophyGenericWorkIdToWorkId < ActiveRecord::Migration
  def change
    rename_column :trophies, :generic_work_id, :work_id
  end
end
