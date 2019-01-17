class ChangeAuditColumnType < ActiveRecord::Migration[4.2]
  def self.up
    adapter = ActiveRecord::Base.configurations[::Rails.env]["adapter"]
    case adapter
    when "postgresql"
      change_column :checksum_audit_logs, :pass, 'integer USING CAST(pass AS integer)'
    else
      change_column :checksum_audit_logs, :pass
    end
  end
  
  def self.down
  end
end
