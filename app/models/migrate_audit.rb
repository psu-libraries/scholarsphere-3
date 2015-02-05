class MigrateAudit < ActiveRecord::Base

  def self.f3_audit(fedora_url, fedora_user, fedora_password, namespace)
    # destroy all existing audit records first
    all.each { |obj| obj.destroy! }

    audit = MigrateAuditFedora3.new(fedora_url, fedora_user, fedora_password, namespace)
    f3_pids = audit.get_pids()
    f3_pids.each do |pid|
      info = audit.get_info(pid)
      create(f3_pid: pid, f3_model: info[:has_model], f3_title: info[:title])
    end
  end

end
