require 'fedora-migrate'

namespace :scholarsphere do

  namespace :migrate do
    desc "Migrates all objects"
    task repository: :environment do
      FedoraMigrate.migrate_repository(namespace: "scholarsphere", options: {convert: "descMetadata", force: true})
      Rake::Task["scholarsphere:migrate:migrate_proxy_deposits"].invoke
      Rake::Task["scholarsphere:migrate:migrate_audit_logs"].invoke
    end
  

    desc "Migrate a single object"
    task :object, [:pid] => :environment do |t, args|
      raise "Please provide a pid, example changeme:1234" if args[:pid].nil?
      FedoraMigrate::ObjectMover.new(
        FedoraMigrate.source.connection.find(args[:pid]), 
        nil, 
        {convert: "descMetadata"}
      ).migrate
    end


    desc "Migrate proxy deposits"
    task migrate_proxy_deposits: :environment do
      ProxyDepositRequest.all.each do |pd|
        pd.pid = pd.pid.delete "#{ScholarSphere::Application.config.id_namespace}:"
        pd.save
      end
    end

    desc "Migrate audit logs"
    task migrate_audit_logs: :environment do
      ChecksumAuditLog.all.each do |cs|
        cs.pid = cs.pid.delete "#{ScholarSphere::Application.config.id_namespace}:"
        cs.save
      end
    end
  end

end
