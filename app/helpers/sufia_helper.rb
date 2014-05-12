module SufiaHelper
  include ::BlacklightHelper
  include Blacklight::CatalogHelperBehavior
  include Sufia::BlacklightOverride
  include Sufia::SufiaHelperBehavior
end
