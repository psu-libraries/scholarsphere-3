# frozen_string_literal: true

# Alters Sufia's API::ZoteroController to add the user_key to the current user.
# This should be removed once Hyrax has this change
module PrependedControllers::WithUserKey
  def callback
    access_token = current_token.get_access_token(oauth_verifier: params['oauth_verifier'])
    # parse userID and API key out of token and store in user instance
    current_user.zotero_userid = access_token.params[:userID]
    current_user.save
    Sufia::Arkivo::CreateSubscriptionJob.perform_later(current_user.user_key)
    redirect_to sufia.profile_path(current_user), notice: 'Successfully connected to Zotero!'
  rescue OAuth::Unauthorized
    redirect_to sufia.edit_profile_path(current_user.to_param), alert: 'Please re-authenticate with Zotero'
  ensure
    current_user.zotero_token = nil
    current_user.save
  end
end
