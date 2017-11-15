# frozen_string_literal: true

def initialize_default_adminset
  permission_template = Sufia::PermissionTemplate.find_by(admin_set_id: AdminSet::DEFAULT_ID)
  if AdminSet.exists?(AdminSet::DEFAULT_ID) && permission_template.blank?
    AdminSet.find(AdminSet::DEFAULT_ID).destroy(eradicate: true)

    # The line above should have deleted the admin set, but sometimes things get stuck
    if AdminSet.exists?(AdminSet::DEFAULT_ID)
      AdminSet.find(AdminSet::DEFAULT_ID).delete
      AdminSet.eradicate(AdminSet::DEFAULT_ID)
    end
  end
  Sufia::AdminSetCreateService.create_default!
  CurationConcerns::Workflow::WorkflowImporter.load_workflows
end
