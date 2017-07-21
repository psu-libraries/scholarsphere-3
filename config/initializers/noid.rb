# frozen_string_literal: true
require "active_fedora/noid"

ActiveFedora::Noid.configure do |config|
  config.minter_class = ActiveFedora::Noid::Minter::Db
  config.template = ".reeeddeeddk"
end
