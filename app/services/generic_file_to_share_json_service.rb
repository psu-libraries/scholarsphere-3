class GenericFileToShareJSONService
  attr_reader :generic_file

  def initialize(generic_file)
    @generic_file = generic_file
    @email_for_name = {}
  end

  def json
    json_hash = {jsonData: {title: title, contributors: contributors, uris: url, providerUpdatedDateTime: providerUpdatedDateTime  } }
    JSON.generate(json_hash)
  end

  private
    def title
      generic_file.title.first
    end

    def contributors
      creators = []
      generic_file.creator.each do |creator|
        hash = {name: creator}
        hash[:email] =  email_for_name(creator)
        creators << hash
      end
      creators
    end

    def providerUpdatedDateTime
      value = generic_file.date_modified
      value = generic_file.date_modified.strftime("%Y-%m-%dT%H:%M:%S.%3N%:z") if generic_file.date_modified.respond_to?(:strftime)
      value
    end

    def url
      {canonicalUri: generic_file.url}
    end

    private
      def email_for_name( name)
        value = NameDisambiguationService.new(name).disambiguate
        return value.blank? ? "" : value[0][:email]
      end
end
