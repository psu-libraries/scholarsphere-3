# properties datastream: catch-all for info that didn't have another home.  Particularly depositor.
class PropertiesDatastream < ActiveFedora::OmDatastream
  include Sufia::PropertiesDatastreamBehavior

  extend_terminology do |t|
    t.proxy_depositor path: 'proxyDepositor', index_as: :symbol

    # This value is set when a user indicates they are depositing this for someone else
    t.on_behalf_of path: 'onBehalfOf', index_as: :symbol
  end
end
