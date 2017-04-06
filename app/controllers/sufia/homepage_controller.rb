# frozen_string_literal: true
class Sufia::HomepageController < ApplicationController
  include Sufia::HomepageControllerBehavior

  protected

    def sort_field
      "#{Solrizer.solr_name('date_uploaded', :stored_sortable, type: :date)} desc"
    end
end
