class MigrateAudit < ActiveRecord::Base
  # This method populates the migrate_audit table with data
  # from the Fedora 3 repo.
  def self.f3_audit!(auditor)
    raise ArgumentError, "Auditor must respond to audit method" unless auditor.respond_to? :audit
    clear_audit_data!
    auditor.audit do |f3_obj|
      create(f3_pid: f3_obj.pid, f3_model: f3_obj.has_model, f3_title: f3_obj.title)
    end
  end

  # This method makes sure each record in the migrate_audit table is
  # in the Fedora 4 repo and it has the same model as its Fedora 3
  # counterpart.
  def self.f4_audit(auditor)
    raise ArgumentError, "Auditor must respond to audit method" unless auditor.respond_to? :audit
    reset_audit_status
    auditor.audit(all) do |result|
      MigrateAudit.update(result.id, f4_id: result.f4_id, status: result.status)
    end
  end

  private

    def self.clear_audit_data!
      # destroy all existing audit records
      all.find_each(&:destroy!)
    end

    def self.reset_audit_status
      MigrateAudit.update_all(f4_id: nil, status: nil)
    end
end
