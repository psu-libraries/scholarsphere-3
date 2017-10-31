# frozen_string_literal: true

module WithCreator
  extend ActiveSupport::Concern

  # @return [Array<CreatorForm>]
  # If there are no creators, a new CreatorForm is built using the logged-in user
  # @todo add Solr search here or in CreatorForm to user existing Alias record for the user
  def creators
    if model.creators.blank?
      Array.wrap(CreatorForm.new(Alias.new(display_name: current_display_name)))
    else
      model.creators.map { |c| CreatorForm.new(c) }
    end
  end

  included do
    def self.build_permitted_params
      permitted = super
      permitted << { creators: [:id, :display_name, :given_name, :sur_name, :psu_id, :email, :orcid_id, :_destroy] }
      permitted
    end
  end

  private

    # @return [String]
    # Sometimes current_ability is really a user
    # @todo See https://github.com/psu-stewardship/scholarsphere/issues/1038
    def current_display_name
      if current_ability.is_a?(User)
        current_ability.display_name
      else
        current_ability.current_user.display_name
      end
    end
end
