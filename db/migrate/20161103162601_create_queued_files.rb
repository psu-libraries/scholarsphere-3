class CreateQueuedFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :queued_files do |t|
      t.string :work_id
      t.string :file_id
      t.string :filename

      t.timestamps null: false
    end
  end
end
