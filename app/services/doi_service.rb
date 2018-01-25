# frozen_string_literal: true

class DOIService
  attr_accessor :client, :handle

  def initialize(handle = ScholarSphere::Application.config.doi_handle,
                 user = ScholarSphere::Application.config.doi_user,
                 password = ScholarSphere::Application.config.doi_password)
    @client = Ezid::Client.new(user: user, password: password)
    @handle = handle
  end

  def run(object)
    current_doi = doi(object)
    return current_doi.first if current_doi.present?

    response = client.mint_identifier(handle, 'datacite.creator' => formatted_creators(object),
                                              'datacite.title' => object.title.first,
                                              'datacite.publisher' => 'ScholarSphere',
                                              'datacite.publicationyear' => '2018',
                                              target: object.url)
    object.identifier += [response.id]
    object.save
    response.id
  end

  private

    def doi(object)
      object.doi
    end

    # @note return a list of creators formatted as Surname, Given; Surname, Given
    def formatted_creators(object)
      object.creators.map do |aliased_creator|
        [aliased_creator.agent.sur_name, aliased_creator.agent.given_name].join(', ')
      end.join('; ')
    end
end
