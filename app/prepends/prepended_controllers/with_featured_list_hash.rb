# frozen_string_literal: true

# Used to return a set of WorkShowPresenters for featured works
module PrependedControllers::WithFeaturedListHash
  protected

    def list_params
      params.require(:featured_work_list).permit(featured_works_attributes: [:id, :order]).to_h
    end
end
