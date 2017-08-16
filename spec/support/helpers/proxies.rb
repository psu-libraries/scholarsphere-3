# frozen_string_literal: true

module ProxiesHelper
  def create_proxy_using_partial(*users)
    users.each do |user|
      expect(User).to receive(:query_ldap_by_name_or_id).and_return([{ id: user.user_key, text: "#{user.display_name} (#{user.user_key})" }])

      first('a.select2-choice').click
      find('.select2-input').set(user.user_key)
      expect(page).to have_css('div.select2-result-label')
      first('div.select2-result-label').click
      within('#authorizedProxies') do
        expect(page).to have_content(user.display_name)
      end
    end
  end

  RSpec.configure do |config|
    config.include ProxiesHelper
  end
end
