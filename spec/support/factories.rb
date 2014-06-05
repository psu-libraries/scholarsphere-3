#  Allows you to just say create(:user) instead of FactoryGirl.create(:user)
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
