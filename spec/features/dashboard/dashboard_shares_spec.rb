require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'Dashboard Shares' do

  let!(:current_user) { create :user }

  specify 'Shares are displayed in the Shared list'
  specify 'Shares are not displayed in the File list'

end
