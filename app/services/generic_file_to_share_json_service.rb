# frozen_string_literal: true
class GenericFileToShareJSONService
  attr_reader :generic_file, :document, :delete

  def initialize(generic_file, opts = {})
    @generic_file = generic_file
    @document = ShareNotify::PushDocument.new(generic_file.url)
    @delete = opts.fetch(:delete, false)
  end

  def json
    document.title = generic_file.title.first
    document.updated = generic_file.date_modified
    add_contributors_to_document
    return false unless document.valid?
    document.delete if delete
    document.to_share.to_json
  end

  private

    def add_contributors_to_document
      generic_file.creator.each do |creator|
        document.add_contributor(name: creator, email: email_for_name(creator))
      end
    end

    def email_for_name(name)
      value = NameDisambiguationService.new(name).disambiguate
      value.blank? ? "" : value[0][:email]
    end
end
