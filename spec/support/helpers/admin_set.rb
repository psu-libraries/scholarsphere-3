# frozen_string_literal: true

def initialize_default_adminset
  permission_template = Sufia::PermissionTemplate.find_by(admin_set_id: AdminSet::DEFAULT_ID)
  if AdminSet.exists?(AdminSet::DEFAULT_ID) && permission_template.blank?
    AdminSet.find(AdminSet::DEFAULT_ID).destroy(eradicate: true)
  end
  Sufia::AdminSetCreateService.create_default!
  CurationConcerns::Workflow::WorkflowImporter.load_workflows
end
