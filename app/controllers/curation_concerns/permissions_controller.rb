# frozen_string_literal: true

class CurationConcerns::PermissionsController < ApplicationController
  include CurationConcerns::PermissionsControllerBehavior

  def confirm_access
    # intentional noop to display default rails view
  end

  # Overrides Sufia to use our own CopyPermissionsJob which does the same things as VisibilityCopyJob
  # and InheritPermissionsJob, but in one job instead of two.
  # Fixes https://github.com/psu-stewardship/scholarsphere/issues/758
  # Remove once we've upgraded to Hyrax
  def copy_access
    authorize! :edit, curation_concern
    CopyPermissionsJob.perform_later(curation_concern)
    redirect_to [main_app, curation_concern], notice: I18n.t('sufia.upload.change_access_flash_message')
  end
end
