class ChangeTrophyGenericFileIdToGenericWorkId < ActiveRecord::Migration[4.2]
  def change
    rename_column :trophies, :generic_file_id, :generic_work_id
  end
end
