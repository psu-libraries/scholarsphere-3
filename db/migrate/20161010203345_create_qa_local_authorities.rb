class CreateQaLocalAuthorities < ActiveRecord::Migration
  def change
    create_table :qa_local_authorities do |t|
      t.string :name

      t.timestamps null: false
    end
    add_index :qa_local_authorities, :name, unique: true
  end
end
