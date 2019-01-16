class ChangeTrophyGenericWorkIdToWorkId < ActiveRecord::Migration[4.2]
  def change
    rename_column :trophies, :generic_work_id, :work_id
  end
end
