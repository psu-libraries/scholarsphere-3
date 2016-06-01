# This migration comes from blacklight (originally 20140320000000)
# frozen_string_literal: true
class AddFileIdToChecksumAuditLogs < ActiveRecord::Migration
  def change
    rename_column :checksum_audit_logs, :dsid, :file_id
  end
end
