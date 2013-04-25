module UserLogin

  def login_as(login)
      driver_name = "rack_test_authenticated_header_#{login}".to_s
      Capybara.register_driver(driver_name) do |app|
        Capybara::RackTest::Driver.new(app, headers: { 'REMOTE_USER' => login })
      end
      user = User.find_or_create_by_login(login)
      User.find_by_login(login).should_not be_nil
      Capybara.current_driver = driver_name
  end  

end