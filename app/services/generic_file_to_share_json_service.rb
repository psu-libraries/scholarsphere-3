class GenericFileToShareJSONService
  attr_reader :generic_file, :document

  def initialize(generic_file)
    @generic_file = generic_file
    @document = ShareNotify::PushDocument.new(generic_file.url)
  end

  def json
    document.title = generic_file.title.first
    document.updated = generic_file.date_modified
    add_contributors_to_document
    return false unless document.valid?
    document.to_share.to_json
  end

  private

    def add_contributors_to_document
      generic_file.creator.each do |creator|
        document.add_contributor(name: creator, email: email_for_name(creator))
      end
    end

    def email_for_name( name)
      value = NameDisambiguationService.new(name).disambiguate
      return value.blank? ? "" : value[0][:email]
    end
end
