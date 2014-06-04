module UserLogin
  def login_as(login)
    driver_name = "rack_test_authenticated_header_#{login}".to_s
    Capybara.register_driver(driver_name) do |app|
      Capybara::RackTest::Driver.new(app,
        respect_data_method: true,
        headers: { 'REMOTE_USER' => login })
    end
    user = User.find_or_create_by(login: login)
    User.find_by_login(login).should_not be_nil
    Capybara.current_driver = driver_name
  end

  class FakeHeaderAuthenticatableStrategy < ::Devise::Strategies::Base

    @@remote_user = "jilluser"

    def self.remote_user=(user)
      @@remote_user = user
    end

    # Called if the user doesn't already have a rails session cookie
    def valid?
      true
    end

    def authenticate!
      u = User.find_by_login(@@remote_user)
      if u.nil?
        u = User.create(login: @@remote_user)
        u.populate_attributes
      end
      u.ldap_available = true
      u.save
      success!(u)
    end
  end

  def login_js (remote_user = 'jilluser')
    FakeHeaderAuthenticatableStrategy.remote_user = remote_user
    spoof_http_auth
  end

  def spoof_http_auth
    Warden::Strategies.add(:http_header_authenticatable, FakeHeaderAuthenticatableStrategy)
  end

  def unspoof_http_auth
    Warden::Strategies.add(:http_header_authenticatable, Devise::Strategies::HttpHeaderAuthenticatable)
  end

  def wait_on_page(text, time=5)
    page.should have_content(text)
  end

  def go_to_dashboard
    visit '/'
    first('a.dropdown-toggle').click
    click_link('my dashboard')
    # causes selenium to wait until text appears on the page
    page.should have_content('My Dashboard')
  end

  def go_to_dashboard_files
    go_to_dashboard
    click_link('View Files')
    page.should have_content('Files')
  end

  def go_to_dashboard_collections
    go_to_dashboard_files
    click_link('Collections')
    page.should have_content('Collections')
  end

  def go_to_dashboard_shares
    go_to_dashboard_files
    click_link('Shared with Me')
    page.should have_content('Shared with Me')
  end

  def go_to_dashboard_highlights
    go_to_dashboard_files
    click_link('Highlighted')
    page.should have_content('Highlighted')
  end
end
