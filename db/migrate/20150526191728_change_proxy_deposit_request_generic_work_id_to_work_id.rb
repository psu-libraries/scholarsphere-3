class ChangeProxyDepositRequestGenericWorkIdToWorkId < ActiveRecord::Migration[4.2]
  def change
    rename_column :proxy_deposit_requests, :generic_work_id, :work_id if ProxyDepositRequest.column_names.include?('generic_work_id')
  end
end
