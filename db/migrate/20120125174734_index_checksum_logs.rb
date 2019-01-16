class IndexChecksumLogs < ActiveRecord::Migration[4.2]
  def self.up
    add_index :checksum_audit_logs, [:pid, :dsid], name:'by_pid_and_dsid', order: {created_at: "DESC" }
  end

  def self.down
    remove_index(:checksum_audit_logs, name: 'by_pid_and_dsid')
  end
end
