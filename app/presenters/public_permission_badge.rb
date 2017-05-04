# frozen_string_literal: true
class PublicPermissionBadge < CurationConcerns::PermissionBadge
  private

    def link_title
      if open_access_with_embargo?
        'Open Access with Embargo'
      elsif open_access?
        I18n.translate('sufia.visibility.open')
      elsif registered?
        I18n.translate('curation_concerns.institution_name')
      else
        'Private'
      end
    end
end
