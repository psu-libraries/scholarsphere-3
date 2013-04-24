module Features
  module SessionHelpers
    def sign_in(who = :user)
      user = who.is_a?(User) ? who : FactoryGirl.find_or_create(who)
      driver_name = "rack_test_authenticated_header_#{user.login}".to_s
      Capybara.register_driver(driver_name) do |app|
        Capybara::RackTest::Driver.new(app, headers: { 'REMOTE_USER' => user.login })
      end
      Capybara.current_driver = driver_name
    end
  end
end

