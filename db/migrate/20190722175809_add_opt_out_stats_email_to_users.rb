class AddOptOutStatsEmailToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :opt_out_stats_email, :boolean
  end
end
