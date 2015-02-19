require 'fedora-migrate'

module FedoraMigrate::Hooks

  # Apply depositor metadata
  def before_object_migration
    xml = Nokogiri::XML(source.datastreams["properties"].content)
    target.apply_depositor_metadata xml.xpath("//depositor").text
  end

end
