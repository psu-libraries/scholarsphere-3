module FixturesHelper
  def test_file_path(filename)
    path = Dir.glob("spec/fixtures/**/#{filename}").first
    Rails.root.join(path).to_s
  end
end

RSpec.configure do |config|
  config.include FixturesHelper
end
