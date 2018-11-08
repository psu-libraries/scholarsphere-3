# frozen_string_literal: true

module BenchmarkSteps
  def login_and_navigate_to_files
    logger.info("Navigating to #{scholarsphere_url}")
    browser.get(scholarsphere_url)

    logger.info('Logging into application')
    browser.find_element(:link, 'Login').click
    browser.find_element(:id, 'login').clear
    browser.find_element(:id, 'login').send_keys ENV['SELENIUM_USERNAME']
    browser.find_element(:id, 'password').clear
    browser.find_element(:id, 'password').send_keys ENV['SELENIUM_PASSWORD']
    browser.find_element(:xpath, '/html/body/div[4]/span/main/form/button').click

    logger.info('Navigating to the "New Work" page')
    browser.get(scholarsphere_url + '/concern/generic_works/new')

    logger.info('Filling out basic metadata')
    browser.find_element(:id, 'generic_work_title').clear
    browser.find_element(:id, 'generic_work_title').send_keys('upload_from_my_computer')
    browser.find_element(:id, 'generic_work_subtitle').clear
    browser.find_element(:id, 'generic_work_subtitle').send_keys('uploaded from filesystem')
    browser.find_element(:id, 'generic_work[creators][0][given_name]').clear
    browser.find_element(:id, 'generic_work[creators][0][given_name]').send_keys(given_name)
    browser.find_element(:id, 'generic_work[creators][0][sur_name]').clear
    browser.find_element(:id, 'generic_work[creators][0][sur_name]').send_keys(sur_name)
    browser.find_element(:id, 'generic_work[creators][0][display_name]').clear
    browser.find_element(:id, 'generic_work[creators][0][display_name]').send_keys(display_name)
    browser.find_element(:id, 'generic_work[creators][0][email]').clear
    browser.find_element(:id, 'generic_work[creators][0][email]').send_keys(email)
    browser.find_element(:id, 'generic_work[creators][0][psu_id]').clear
    browser.find_element(:id, 'generic_work[creators][0][psu_id]').send_keys(psu_id)
    browser.find_element(:id, 'generic_work_keyword').clear
    browser.find_element(:id, 'generic_work_keyword').send_keys(keyword)
    browser.find_element(:id, 'generic_work_rights').click
    browser.find_element(:xpath, '//*[@id="generic_work_rights"]/option[2]').click
    browser.find_element(:id, 'generic_work_description').clear
    browser.find_element(:id, 'generic_work_description').send_keys(work_description)
    browser.find_element(:xpath, '//*[@id="generic_work_resource_type"]/option[1]').click

    logger.info('Navigating to the Files page')
    browser.find_element(:xpath, '//*[@id="new_generic_work"]/div/div[1]/ul/li[2]/a').click
  end

  def upload_files_from_my_computer
    logger.info('Selecting files for upload')
    sample_files.each do |file|
      browser.find_element(:id, 'inputfiles').send_keys("#{samples_directory}/#{file}")
    end

    logger.info('Uploading the work file')
    browser.find_element(:xpath, '//*[@id="all_files"]/div[1]/button').click

    logger.info('Waiting until the file is finished uploading...')
    sample_files.each_with_index do |_file, index|
      browser.find_element(
        :xpath,
        '/html/body/div[1]/div/form/div/div[1]/div/div[2]/div/div/table/tbody/tr['\
        "#{index + 1}"\
        "]/td[3]/button[@class='btn btn-danger delete']"
      )
    end
  end

  def submit_new_work
    logger.info('Selecting the default embargo option')
    browser.find_element(:id, 'generic_work_visibility_embargo').click

    logger.info('Accepting depositor agreement')
    browser.find_element(:id, 'agreement').click

    logger.info('Submitting new work')
    browser.find_element(:id, 'with_files_submit').click
  end

  def upload_files_from_box
    logger.info('Connecting to Box')
    browser.find_element(:id, 'browse-btn').click
    browser.find_element(:id, 'provider_auth').click
    browser.switch_to.window(browser.window_handles.last)

    logger.info('Logging into box')
    browser.find_element(:id, 'login').clear
    browser.find_element(:id, 'login').send_keys(ENV['BOX_USERNAME'])
    browser.find_element(:id, 'password').clear
    browser.find_element(:id, 'password').send_keys(ENV['BOX_PASSWORD'])
    browser.find_element(
      :xpath,
      '/html/body/div[3]/div/div[1]/div[2]/div/div[1]/form/div[1]/div[2]/input'
    ).click

    logger.info('Granting Box access to Scholarsphere')
    browser.find_element(:id, 'consent_accept_button').click
    browser.switch_to.window(browser.window_handles.last)

    logger.info('Selecting files for the new work')
    sample_files.each_with_index do |_filename, index|
      browser.find_element(
        :xpath,
        "//*[@id='file-list']/tbody/tr[#{index + 1}]/td[1]/a"
      ).click
    end
    browser.find_element(
      :xpath,
      '//*[@id="browse-everything"]/div/div/div[3]/form/button[2]'
    ).click

    logger.info('Navigating to the metadata page')
    while element_visibility
      sleep 1
    end
    sleep 2
  end

  def refresh_until_complete
    logger.info('Detecting when the page has changed to the new work')
    browser.find_element(:xpath, '/html/body/div[1][@class="alert alert-success alert-dismissable"]')

    logger.info('Waiting until work elements are present')
    refresh_until_element_present(
      element_path: '/html/body/div[1]/div/div[2]/div/table/tbody/tr[NUMBER]/td[1]/a/img',
      browser: browser
    )

    logger.info('Waiting until resque jobs are complete')
    refresh_until_resque_complete(
      element_path: '/html/body/div[1]/div/div[2]/div/table/tbody/tr[NUMBER]/td[1]/a/img',
      browser: browser
    )
  end

  def element_visibility
    style = browser.find_element(:id, 'browse-everything').style('display')
    style =~ /block/ ? true : false
  end

  def refresh_until_element_present(element_path:, browser:)
    logger.info('Refreshing page until element is present')
    sleep(2)
    browser.manage.timeouts.implicit_wait = 1
    sample_files.each_with_index do |_filename, index|
      element_path_iteration = element_path.sub(/NUMBER/, (index + 1).to_s)
      browser.find_element(:xpath, element_path_iteration)
    end
  rescue StandardError => exception
    Selenium::WebDriver::Error::NoSuchElementError
    logger.info("Rescued #{exception.class}")
    browser.navigate.refresh
    refresh_until_element_present(element_path: element_path, browser: browser)
  ensure
    browser.manage.timeouts.implicit_wait = implicit_wait_time
  end

  def refresh_until_resque_complete(element_path:, browser:)
    logger.info('Refreshing page until Resque jobs are finished')
    sleep(2)
    sample_files.each_with_index do |_filename, index|
      element_path_iteration = element_path.sub(/NUMBER/, (index + 1).to_s)
      if browser.find_element(:xpath, element_path_iteration).attribute('src').include?('/assets')
        browser.navigate.refresh
        refresh_until_resque_complete(element_path: element_path, browser: browser)
      end
    end
  end
end
