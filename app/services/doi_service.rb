# frozen_string_literal: true

class DOIService
  attr_accessor :client, :handle

  EZID_RESOURCE_TYPES = {
    'Article' => 'Text',
    'Audio' => 'Sound',
    'Book' => 'Book',
    'Capstone Project' => 'Text',
    'Conference Proceeding' => 'Text',
    'Dataset' => 'Dataset',
    'Image' => 'Image',
    'Journal' => 'Text',
    'Map or Cartographic Material' => 'Image',
    'Part of Book' => 'Text',
    'Poster' => 'Audiovisual',
    'Presentation' => 'Audiovisual',
    'Project' => 'Other',
    'Report' => 'Text',
    'Research Paper' => 'Text',
    'Software or Program Code' => 'Software',
    'Video' => 'Audiovisual',
    'Other' => 'Other'
  }.freeze

  def initialize(handle = ScholarSphere::Application.config.doi_handle,
                 user = ScholarSphere::Application.config.doi_user,
                 password = ScholarSphere::Application.config.doi_password)
    @client = Ezid::Client.new(user: user, password: password)
    @handle = handle
  end

  def run(object)
    current_doi = doi(object)
    return current_doi.first if current_doi.present?

    response = client.mint_identifier(handle, response_body(object))
    object.identifier += [response.id]
    object.save
    response.id
  end

  private

    def doi(object)
      object.doi
    end

    def response_body(object)
      if object.resource_type.empty?
        base_body(object)
      else
        base_body(object).merge!('datacite.resourcetype' => EZID_RESOURCE_TYPES[object.resource_type.first])
      end
    end

    def base_body(object)
      {
        'datacite.creator' => formatted_creators(object),
        'datacite.title' => object.title.first,
        'datacite.publisher' => 'ScholarSphere',
        'datacite.publicationyear' => '2018',
        target: object.url
      }
    end

    # @note return a list of creators formatted as Surname, Given; Surname, Given
    def formatted_creators(object)
      object.creators.map do |aliased_creator|
        [aliased_creator.agent.sur_name, aliased_creator.agent.given_name].join(', ')
      end.join('; ')
    end
end
