# frozen_string_literal: true
FactoryGirl.define do
  # Fedora 3 to Fedora 4 Migration Audit
  factory :f3_file_migrated, class: MigrateAudit do |_x|
    f3_pid 'scholarsphere:111xyzfile'
    f3_model "info:fedora/afmodel:GenericFile"
    f3_title "Some file in Fedora 3"
  end

  factory :f3_file_not_migrated, class: MigrateAudit do |_x|
    f3_pid 'scholarsphere:222xyzfile'
    f3_model "info:fedora/afmodel:GenericFile"
    f3_title "Some file in Fedora 3 that won't be migrated"
  end

  factory :f3_file_migrated_wrong, class: MigrateAudit do |_x|
    f3_pid 'scholarsphere:333xyzfile'
    f3_model "info:fedora/afmodel:GenericFileFake"
    f3_title "Some file in Fedora 3 that will be migrated with the wrong model"
  end
end
