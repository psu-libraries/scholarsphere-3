class MigrateAudit < ActiveRecord::Base

  # This method populates the migrateaudit table with data 
  # from the Fedora 3 repo.
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

  # This method makes sure each record in the migrateaudit table is
  # in the Fedora 4 repo and it has the same model as its Fedora 3
  # counterpart.
  def self.f4_audit(fedora_url, fedora_user, fedora_password)
    f3_data = all
    audit = MigrateAuditFedora4.new(fedora_url, fedora_user, fedora_password)
    results = audit.audit(f3_data)
    results.each do |result|
      puts result
    end
  end
end
