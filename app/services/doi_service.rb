# frozen_string_literal: true

class DOIService
  attr_accessor :client, :handle

  EZID_RESOURCE_TYPES = {
    'Article' => 'Text',
    'Audio' => 'Sound',
    'Book' => 'Text',
    'Capstone Project' => 'Text',
    'Conference Proceeding' => 'Text',
    'Dissertation' => 'Text',
    'Dataset' => 'Dataset',
    'Image' => 'Image',
    'Journal' => 'Text',
    'Map or Cartographic Material' => 'Image',
    'Masters Thesis' => 'Text',
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

  # @note user, password, and host values for the Ezid::Client are obtained from environment variables
  #   set in application.yml. The hostname can be either an EZID API service or the new DataCite EZ API.
  def initialize(handle = ScholarSphere::Application.config.doi_handle)
    @client = Ezid::Client.new
    @handle = handle
  end

  def run(object)
    current_doi = doi(object)
    return current_doi.first if current_doi.present?

    begin
      response = client.mint_identifier(handle, response_body(object))
      object.identifier += [response.id]
      object.save
      response.id
    rescue Ezid::Error => e
      Rails.logger.warn "Got an Ezid::Error: #{e}, No DOI was created!"
      DOIFailureJob.perform_later(object, User.find_by(login: object.depositor))
    end
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
      date_uploaded = object.date_uploaded || Time.now
      {
        'datacite.creator' => formatted_creators(object),
        'datacite.title' => object.title.first,
        'datacite.publisher' => 'ScholarSphere',
        'datacite.publicationyear' => date_uploaded.year.to_s,
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
