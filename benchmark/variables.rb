# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:context) do
    @scholarsphere_url = 'https://scholarsphere-qa.libraries.psu.edu/'
    @headless = false
    @implicit_wait_time = 180
    @samples_directory = Pathname.pwd.join('samples').to_s
    @sample_files = Pathname.pwd.join('samples').children.map(&:basename).map(&:to_s)
    @given_name = 'Malcom'
    @sur_name = 'Reynolds'
    @display_name = 'Captain Malcom Reynolds'
    @email = 'captain@serenity.com'
    @psu_id = 'malbad@psu.edu'
    @keyword = "KEYWORD_#{rand(10000..99999)}"
    @work_description = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
  end
end
