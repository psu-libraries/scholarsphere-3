# Unload the default factories that got loaded in spec/factories. We
# want to use these factories exclusively until this test suite is
# merged with the default test suite.
FactoryGirl.factories.clear
FactoryGirl.definition_file_paths = %w{ spec.features/factories }
FactoryGirl.find_definitions

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
