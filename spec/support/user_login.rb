module UserLogin
  def login_as(login)
    driver_name = "rack_test_authenticated_header_#{login}".to_s
    Capybara.register_driver(driver_name) do |app|
      Capybara::RackTest::Driver.new(app,
        respect_data_method: true,
        headers: { 'REMOTE_USER' => login })
    end
    user = User.find_or_create_by(login: login)
    expect(User.find_by_login(login)).not_to be_nil
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
    user = User.where(login:remote_user).first
    user ||= User.create(login:remote_user, display_name:remote_user, ldap_available: true)
    sign_in_as user
  end

  def spoof_http_auth
    Warden::Strategies.add(:http_header_authenticatable, FakeHeaderAuthenticatableStrategy)
  end

  def unspoof_http_auth
    Warden::Strategies.add(:http_header_authenticatable, Devise::Strategies::HttpHeaderAuthenticatable)
  end

  def wait_on_page(text, time=5)
    expect(page).to have_content(text)
  end

end
