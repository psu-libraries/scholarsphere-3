# frozen_string_literal: true

module BenchmarkConfig
  def scholarsphere_url
    ENV.fetch('BENCHMARK_URL', 'https://scholarsphere-qa.libraries.psu.edu/')
  end

  def headless
    return false if ENV.fetch('BENCHMARK_HEADLESS', true) == 'false'
    true
  end

  def implicit_wait_time
    180
  end

  def samples_directory
    Pathname.pwd.join('samples').to_s
  end

  def sample_files
    Pathname.pwd.join('samples').children.map(&:basename).map(&:to_s)
  end

  def given_name
    Faker::Name.first_name
  end

  def sur_name
    Faker::Name.last_name
  end

  def display_name
    Faker::Name.name_with_middle
  end

  def email
    "#{ENV['SELENIUM_USERNAME']}@psu.edu"
  end
  alias psu_id email

  def keyword
    "KEYWORD_#{rand(10000..99999)}"
  end

  def work_description
    Faker::Lorem.paragraphs.join(' ')
  end
end
