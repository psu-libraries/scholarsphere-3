class CreateSuperusers < ActiveRecord::Migration[4.2]
  def self.up
    create_table :superusers do |t|
      t.integer :user_id, null:false
    end
  end

  def self.down
    drop_table :superusers
  end

end
