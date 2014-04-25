module FixturesHelper

  def test_file_path filename
    Rails.root.join("spec/fixtures/#{filename}").to_s
  end
end

RSpec.configure do |config|
  config.include FixturesHelper
end
