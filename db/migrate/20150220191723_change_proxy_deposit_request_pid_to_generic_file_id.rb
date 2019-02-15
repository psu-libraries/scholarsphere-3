class ChangeProxyDepositRequestPidToGenericFileId < ActiveRecord::Migration[4.2]
  def change
    rename_column :proxy_deposit_requests, :pid, :generic_file_id
  end
end
