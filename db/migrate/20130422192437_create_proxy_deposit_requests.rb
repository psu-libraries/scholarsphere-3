class CreateProxyDepositRequests < ActiveRecord::Migration
  def change
    create_table :proxy_deposit_requests do |t|
      t.string :pid, null: false
      t.string :sending_user, null: false
      t.references :receiving_user, null: false
      t.datetime :fulfillment_date
      t.timestamps
    end
    add_index :proxy_deposit_requests, :receiving_user_id
  end
end
